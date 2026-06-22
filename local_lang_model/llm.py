#!/usr/bin/env python3
"""
Local Language Model Chat - Elegant LLM interface for Ollama
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Dark-mode chat UI with RAM-aware auto model selection.
Streams responses in real-time, persists chat history, and renders a
Hubble Deep Field background. Blue gradient bubbles, smooth scrolling.

Setup:
  pip install requests markdown psutil PyQt6
  ollama serve            # must be running
  place hubbleUltraDeepField.png next to this script (optional)
"""
import sys
import json
import requests
import markdown
import psutil
from pathlib import Path
from datetime import datetime
from PyQt6.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
                             QTextEdit, QPushButton, QScrollArea, QLabel, QListWidget,
                             QListWidgetItem, QSplitter, QTextBrowser, QProgressBar, QFrame)
from PyQt6.QtCore import Qt, QThread, pyqtSignal, QTimer
from PyQt6.QtGui import QFont

# ── Paths / config ───────────────────────────────────────────────
SCRIPT_DIR = Path(__file__).parent
HISTORY_DIR = SCRIPT_DIR / 'chat_history'
HISTORY_DIR.mkdir(exist_ok=True)
API_URL = 'http://localhost:11434/api/chat'
BG_IMAGE = SCRIPT_DIR / 'hubbleUltraDeepField.png'

# Local Ollama models only. reasoning models preferred, then larger params.
MODELS = {
    'deepseek-r1:14b': {'reasoning': True, 'params': 14},
    'deepseek-r1:7b': {'reasoning': True, 'params': 7},
    'qwen3:14b-instruct': {'reasoning': False, 'params': 14},
    'gemma2:27b': {'reasoning': False, 'params': 27},
    'gemma2:9b': {'reasoning': False, 'params': 9},
    'llama3:8b': {'reasoning': False, 'params': 8},
    'llama3:70b': {'reasoning': False, 'params': 70},
    'llama2:7b': {'reasoning': False, 'params': 7},
    'mistral:7b': {'reasoning': False, 'params': 7},
    'mixtral:8x7b': {'reasoning': False, 'params': 56},
    'neural-chat:7b': {'reasoning': False, 'params': 7},
    'starling-lm:7b': {'reasoning': False, 'params': 7},
    'gemma2:2b': {'reasoning': False, 'params': 2},
}

DARK = '''
QMainWindow, QWidget { background: #0a0e27; color: #e0e0e0; }
QTextEdit { background: rgba(42, 42, 58, 0.95); color: #e0e0e0; border: 1px solid #667eea; border-radius: 12px; padding: 12px; font-size: 11pt; }
QTextEdit:focus { border: 2px solid #667eea; background: rgba(42, 42, 58, 0.98); }
QTextBrowser { background: transparent; color: #e0e0e0; border: none; }
QListWidget { background: rgba(25, 25, 40, 0.95); border: none; }
QListWidget::item { padding: 10px; border-bottom: 1px solid #333; }
QListWidget::item:selected { background: #667eea; color: white; }
QPushButton { background: #667eea; color: white; border: none; padding: 12px 20px; border-radius: 8px; font-weight: bold; font-size: 10pt; }
QPushButton:hover { background: #7c8ff0; }
QPushButton:pressed { background: #5568d3; }
QLabel { color: #e0e0e0; }
QProgressBar { background: rgba(42, 42, 58, 0.8); border: none; border-radius: 6px; }
QProgressBar::chunk { background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #667eea, stop:1 #764ba2); border-radius: 6px; }
QSplitter::handle { background: #333; width: 8px; }
QSplitter::handle:hover { background: #667eea; }
'''

MD_CSS = '''<style>
body { font-family: 'Segoe UI', Tahoma, sans-serif; margin: 0; color: #e0e0e0; }
code { background: rgba(26, 26, 40, 0.9); color: #4ec9b0; padding: 3px 6px; border-radius: 4px; font-family: 'Courier New', monospace; }
pre { background: rgba(26, 26, 40, 0.95); color: #d4d4d4; padding: 14px 16px; border-radius: 6px; border-left: 4px solid #667eea; overflow-x: auto; margin: 10px 0; }
h1, h2, h3 { color: #667eea; margin-top: 12px; margin-bottom: 8px; }
a { color: #7c8ff0; text-decoration: none; }
a:hover { text-decoration: underline; }
blockquote { border-left: 4px solid #667eea; padding-left: 14px; color: #a0a0a0; margin-left: 0; }
p { margin: 6px 0; line-height: 1.5; }
li { margin: 4px 0; }
</style>'''


class Worker(QThread):
    """Background thread for streaming API requests."""
    chunk = pyqtSignal(str)
    done = pyqtSignal(str)
    error = pyqtSignal(str)

    def __init__(self, msgs, model):
        super().__init__()
        self.msgs = msgs
        self.model = model

    def run(self):
        try:
            resp = requests.post(
                API_URL,
                json={'model': self.model, 'messages': self.msgs, 'stream': True},
                stream=True,
                timeout=300,
            )
            resp.raise_for_status()
            full = ''
            for line in resp.iter_lines():
                if line:
                    try:
                        data = json.loads(line)
                        chunk = data.get('message', {}).get('content', '')
                        if chunk:
                            full += chunk
                            self.chunk.emit(chunk)
                    except json.JSONDecodeError:
                        pass
            self.done.emit(full)
        except Exception as e:
            self.error.emit(str(e))


class ModelDetector(QThread):
    """Detect best available model off the UI thread."""
    found = pyqtSignal(str)
    failed = pyqtSignal(str)

    def run(self):
        try:
            self.found.emit(get_model())
        except Exception as e:
            self.failed.emit(str(e))


class ChatApp(QMainWindow):
    """Main chat application with integrated splash screen."""
    def __init__(self):
        super().__init__()
        self.model = None
        self.msgs = []
        self.chat_id = 'default'
        self.worker = None
        self.detector = None
        self.response_browser = None

        self.setWindowTitle('Local Language Model')
        self.setGeometry(0, 0, 1600, 900)
        self.showMaximized()
        self.setStyleSheet(DARK)

        self.show_splash_screen()

    # ── Splash ───────────────────────────────────────────────────
    def show_splash_screen(self):
        splash_widget = QWidget()
        splash_layout = QVBoxLayout(splash_widget)
        splash_layout.setContentsMargins(60, 60, 60, 60)
        splash_layout.setSpacing(30)

        title = QLabel('⚡ Local Language Model')
        title.setFont(QFont('Segoe UI', 48, QFont.Weight.Bold))
        title.setStyleSheet('color: #667eea; letter-spacing: 2px;')
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        splash_layout.addWidget(title)

        subtitle = QLabel('Intelligent conversations, locally')
        subtitle.setFont(QFont('Segoe UI', 14))
        subtitle.setStyleSheet('color: #a0a0a0;')
        subtitle.setAlignment(Qt.AlignmentFlag.AlignCenter)
        splash_layout.addWidget(subtitle)

        splash_layout.addSpacing(20)

        info_frame = QFrame()
        info_frame.setStyleSheet('''
            QFrame { background: rgba(42, 42, 58, 0.8); border: 1px solid #667eea;
                     border-radius: 10px; padding: 20px; }
        ''')
        info_layout = QVBoxLayout(info_frame)
        info_layout.setSpacing(12)

        specs = psutil.virtual_memory()
        cpu_count = psutil.cpu_count()
        ram_total = specs.total / (1024 ** 3)
        ram_used = specs.used / (1024 ** 3)
        ram_pct = specs.percent
        cpu_pct = psutil.cpu_percent(interval=0.1)

        header = QLabel('System Specifications')
        header.setFont(QFont('Segoe UI', 12, QFont.Weight.Bold))
        header.setStyleSheet('color: #667eea;')
        info_layout.addWidget(header)

        info_layout.addWidget(self._spec(f'🖥️  CPU Cores: {cpu_count}'))
        info_layout.addWidget(self._spec(f'🧠 Memory: {ram_used:.1f}GB / {ram_total:.1f}GB ({ram_pct:.0f}%)'))

        ram_bar = QProgressBar()
        ram_bar.setValue(int(ram_pct))
        ram_bar.setTextVisible(False)
        ram_bar.setMinimumHeight(6)
        info_layout.addWidget(ram_bar)

        info_layout.addWidget(self._spec(f'⚙️  CPU Usage: {cpu_pct:.1f}%'))

        cpu_bar = QProgressBar()
        cpu_bar.setValue(int(cpu_pct))
        cpu_bar.setTextVisible(False)
        cpu_bar.setMinimumHeight(6)
        info_layout.addWidget(cpu_bar)

        splash_layout.addWidget(info_frame)
        splash_layout.addSpacing(20)

        self.status_label = QLabel('🔍 Detecting models...')
        self.status_label.setFont(QFont('Segoe UI', 12))
        self.status_label.setStyleSheet('color: #4ec9b0;')
        self.status_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        splash_layout.addWidget(self.status_label)

        self.model_label = QLabel('')
        self.model_label.setFont(QFont('Segoe UI', 16, QFont.Weight.Bold))
        self.model_label.setStyleSheet('color: #667eea;')
        self.model_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        splash_layout.addWidget(self.model_label)

        splash_layout.addStretch()
        self.setCentralWidget(splash_widget)

        self.detector = ModelDetector()
        self.detector.found.connect(self._on_model_ready)
        self.detector.failed.connect(self._on_model_failed)
        self.detector.start()

    def _spec(self, text):
        lbl = QLabel(text)
        lbl.setFont(QFont('Segoe UI', 11))
        return lbl

    def _on_model_ready(self, model):
        self.model = model
        self.model_label.setText(f'✓ Selected: {model}')
        self.setWindowTitle(f'Local Language Model • {model}')
        QTimer.singleShot(1500, self.show_chat)

    def _on_model_failed(self, err):
        self.status_label.setText(f'❌ {err}')
        QTimer.singleShot(3500, self.close)

    # ── Main chat UI ─────────────────────────────────────────────
    def show_chat(self):
        main_widget = QWidget()
        main_layout = QHBoxLayout(main_widget)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.setSpacing(0)

        splitter = QSplitter(Qt.Orientation.Horizontal)

        # LEFT: sidebar
        self.sidebar = QWidget()
        sidebar_layout = QVBoxLayout(self.sidebar)
        sidebar_layout.setContentsMargins(0, 0, 0, 0)
        sidebar_layout.setSpacing(0)

        top_bar = QWidget()
        top_bar.setStyleSheet('background: rgba(26, 26, 45, 0.95); border-bottom: 1px solid #667eea;')
        top_bar_layout = QHBoxLayout(top_bar)
        top_bar_layout.setContentsMargins(12, 12, 12, 12)

        self.new_chat_full_btn = QPushButton('+ New Chat')
        self.new_chat_full_btn.setMinimumHeight(40)
        self.new_chat_full_btn.clicked.connect(self.new_chat)
        top_bar_layout.addWidget(self.new_chat_full_btn)
        sidebar_layout.addWidget(top_bar)

        self.history = QListWidget()
        self.history.itemClicked.connect(self.load_from_history)
        sidebar_layout.addWidget(self.history, 1)

        # RIGHT: chat area
        chat_area = QWidget()
        chat_area_layout = QVBoxLayout(chat_area)
        chat_area_layout.setContentsMargins(0, 0, 0, 0)
        chat_area_layout.setSpacing(0)

        header = QFrame()
        header.setStyleSheet('''
            QFrame { background: rgba(26, 26, 45, 0.95);
                     border-bottom: 1px solid #667eea; padding: 12px 20px; }
        ''')
        header_layout = QHBoxLayout(header)
        header_layout.setContentsMargins(0, 0, 0, 0)

        self.new_chat_plus_btn = QPushButton('+')
        self.new_chat_plus_btn.setMaximumWidth(45)
        self.new_chat_plus_btn.setMaximumHeight(45)
        self.new_chat_plus_btn.setFont(QFont('Arial', 16, QFont.Weight.Bold))
        self.new_chat_plus_btn.setStyleSheet('background: #667eea; color: white; border: none; border-radius: 8px;')
        self.new_chat_plus_btn.clicked.connect(self.new_chat)
        header_layout.addWidget(self.new_chat_plus_btn)

        model_display = QLabel(f'💬 Chatting with: {self.model}')
        model_display.setFont(QFont('Segoe UI', 11, QFont.Weight.Bold))
        model_display.setStyleSheet('color: #667eea;')
        header_layout.addWidget(model_display)
        header_layout.addStretch()
        chat_area_layout.addWidget(header)

        # Scroll area with Hubble background (graceful fallback if PNG missing)
        self.scroll = QScrollArea()
        self.scroll.setWidgetResizable(True)
        if BG_IMAGE.exists():
            bg_url = str(BG_IMAGE).replace('\\', '/')
            bg_rule = (f"background-image: url('{bg_url}'); background-attachment: fixed; "
                       "background-position: center center; background-repeat: no-repeat; "
                       "background-size: cover;")
        else:
            bg_rule = "background: #05070f;"
        self.scroll.setStyleSheet(f'''
            QScrollArea {{ {bg_rule} border: none; margin: 0; padding: 0; }}
            QScrollBar:vertical {{ background: rgba(42, 42, 58, 0.5); width: 10px; border-radius: 5px; }}
            QScrollBar::handle:vertical {{ background: #667eea; border-radius: 5px; min-height: 20px; }}
        ''')

        self.chat_content = QWidget()
        self.chat_content.setStyleSheet('background: transparent;')
        self.chat_layout = QVBoxLayout(self.chat_content)
        self.chat_layout.setContentsMargins(20, 20, 20, 20)
        self.chat_layout.setSpacing(12)
        self.chat_layout.addStretch()
        self.scroll.setWidget(self.chat_content)
        chat_area_layout.addWidget(self.scroll, 1)

        # Input area
        input_frame = QWidget()
        input_frame.setStyleSheet('background: rgba(10, 14, 39, 0.95); border-top: 1px solid #667eea;')
        input_layout = QVBoxLayout(input_frame)
        input_layout.setContentsMargins(16, 16, 16, 16)

        input_row = QHBoxLayout()
        input_row.setSpacing(10)

        self.input = QTextEdit()
        self.input.setMaximumHeight(70)
        self.input.setPlaceholderText('Type your message... (Enter to send, Shift+Enter for newline)')
        self.input.keyPressEvent = self.on_key
        input_row.addWidget(self.input)

        self.send_btn = QPushButton('↑')
        self.send_btn.setMaximumWidth(50)
        self.send_btn.setMaximumHeight(70)
        self.send_btn.setFont(QFont('Arial', 18, QFont.Weight.Bold))
        self.send_btn.clicked.connect(self.send)
        input_row.addWidget(self.send_btn)

        input_layout.addLayout(input_row)
        chat_area_layout.addWidget(input_frame, 0)

        splitter.addWidget(self.sidebar)
        splitter.addWidget(chat_area)
        splitter.setCollapsible(0, True)
        splitter.setCollapsible(1, False)
        splitter.setStretchFactor(0, 0)
        splitter.setStretchFactor(1, 1)
        splitter.setSizes([0, 1600])  # sidebar hidden by default

        def on_splitter_moved():
            if splitter.sizes()[0] > 50:
                self.new_chat_plus_btn.hide()
            else:
                self.new_chat_plus_btn.show()
        splitter.splitterMoved.connect(on_splitter_moved)

        main_layout.addWidget(splitter)
        self.setCentralWidget(main_widget)

        self.refresh_history()
        self.load_chat('default')

    # ── Interaction ──────────────────────────────────────────────
    def on_key(self, event):
        if event.key() == Qt.Key.Key_Return:
            if event.modifiers() == Qt.KeyboardModifier.ShiftModifier:
                self.input.insertPlainText('\n')
            else:
                self.send()
            event.accept()
        else:
            QTextEdit.keyPressEvent(self.input, event)

    def send(self):
        text = self.input.toPlainText().strip()
        if not text or self.worker:
            return
        self.msgs.append({'role': 'user', 'content': text})
        self.add_msg('user', text)
        self.input.clear()
        self.input.setDisabled(True)
        self.send_btn.setDisabled(True)
        self.response_browser = None

        self.worker = Worker(self.msgs, self.model)
        self.worker.chunk.connect(self.add_chunk)
        self.worker.done.connect(self.on_done)
        self.worker.error.connect(self.on_error)
        self.worker.start()

    def add_msg(self, role, text):
        container = QWidget()
        container.setStyleSheet('background: transparent;')
        cl = QHBoxLayout(container)
        cl.setContentsMargins(0, 0, 0, 0)
        cl.setSpacing(0)

        if role == 'user':
            cl.addStretch()
            bubble = QLabel(text)
            bubble.setWordWrap(True)
            bubble.setFont(QFont('Segoe UI', 10))
            bubble.setStyleSheet('''
                QLabel { background: qlineargradient(x1:0, y1:0, x2:1, y2:1, stop:0 #5a67d8, stop:1 #667eea);
                         color: white; padding: 12px 16px; border-radius: 16px; border-top-right-radius: 4px; }
            ''')
            bubble.setMaximumWidth(700)
            cl.addWidget(bubble)
        else:
            bubble = QTextBrowser()
            bubble.setReadOnly(True)
            bubble.setMaximumWidth(750)
            bubble.setFont(QFont('Segoe UI', 10))
            bubble.setStyleSheet('''
                QTextBrowser { background: rgba(26, 26, 45, 0.85); color: #e0e0e0;
                               border: 1px solid #5a67d8; border-radius: 16px;
                               border-top-left-radius: 4px; padding: 12px 16px; }
            ''')
            cl.addWidget(bubble)
            cl.addStretch()
            self.response_browser = bubble
            if text:
                bubble.setHtml(MD_CSS + markdown.markdown(text, extensions=['extra', 'codehilite']))

        self.chat_layout.insertWidget(self.chat_layout.count() - 1, container)
        QTimer.singleShot(50, self.scroll_down)

    def add_chunk(self, chunk):
        if self.response_browser is None:
            self.add_msg('assistant', '')
        current = self.response_browser.toPlainText()
        html = MD_CSS + markdown.markdown(current + chunk, extensions=['extra', 'codehilite'])
        self.response_browser.setHtml(html)
        self.scroll_down()

    def on_done(self, full):
        self.msgs.append({'role': 'assistant', 'content': full})
        self.save()
        self.worker = None
        self.input.setDisabled(False)
        self.send_btn.setDisabled(False)
        self.input.setFocus()

    def on_error(self, err):
        self.add_msg('assistant', f'⚠️ Error: {err}')
        self.worker = None
        self.input.setDisabled(False)
        self.send_btn.setDisabled(False)

    def scroll_down(self):
        sb = self.scroll.verticalScrollBar()
        sb.setValue(sb.maximum())

    # ── Persistence ──────────────────────────────────────────────
    def clear(self):
        for i in reversed(range(self.chat_layout.count() - 1)):
            w = self.chat_layout.itemAt(i).widget()
            if w:
                w.deleteLater()

    def new_chat(self):
        self.chat_id = datetime.now().strftime('%Y%m%d_%H%M%S')
        self.msgs = []
        self.response_browser = None
        self.clear()
        self.refresh_history()

    def save(self):
        with open(HISTORY_DIR / f'{self.chat_id}.json', 'w') as f:
            json.dump(self.msgs, f, indent=2)

    def load_chat(self, chat_id):
        path = HISTORY_DIR / f'{chat_id}.json'
        self.msgs = []
        self.response_browser = None
        if path.exists():
            try:
                with open(path) as f:
                    self.msgs = json.load(f)
            except json.JSONDecodeError:
                self.msgs = []
        self.chat_id = chat_id
        self.clear()
        for msg in self.msgs:
            self.add_msg(msg['role'], msg['content'])

    def load_from_history(self, item):
        self.load_chat(item.data(Qt.ItemDataRole.UserRole))

    def refresh_history(self):
        self.history.clear()
        chats = sorted(
            (f for f in HISTORY_DIR.glob('*.json') if f.stem != 'default'),
            key=lambda p: p.stat().st_mtime, reverse=True,
        )
        for f in chats:
            item = QListWidgetItem(f.stem.replace('_', ' '))
            item.setData(Qt.ItemDataRole.UserRole, f.stem)
            self.history.addItem(item)


def get_model():
    """Pick best model that fits in free RAM, preferring reasoning then size."""
    free_ram = psutil.virtual_memory().available / (1024 ** 3)
    candidates = []
    for model, info in MODELS.items():
        if info['params'] * 2 > free_ram:   # rough fp16-ish RAM estimate
            continue
        candidates.append((model, (-int(info['reasoning']), -info['params'])))
    candidates.sort(key=lambda x: x[1])

    for model, _ in candidates:
        try:
            requests.post(API_URL,
                          json={'model': model, 'messages': [{'role': 'user', 'content': 'test'}], 'stream': False},
                          timeout=2)
            return model
        except Exception:
            continue
    raise RuntimeError('No Ollama models available. Run: ollama serve')


def main():
    app = QApplication(sys.argv)
    window = ChatApp()
    window.show()
    sys.exit(app.exec())


if __name__ == '__main__':
    main()

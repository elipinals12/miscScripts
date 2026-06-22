# Define a new .NET class using the Add-Type cmdlet.
# This class will contain the necessary methods and constants for mouse clicking.
Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    // Define a class named Clicker
    public class Clicker {
        // Import the mouse_event function from user32.dll
        [DllImport("user32.dll", CharSet=CharSet.Auto, CallingConvention=CallingConvention.StdCall)]
        public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);

        // Define constants for mouse event flags
        public const int MOUSEEVENTF_LEFTDOWN = 0x02;
        public const int MOUSEEVENTF_LEFTUP = 0x04;

        // Define a method named Click, which simulates a left mouse button click
        public static void Click() {
            mouse_event(MOUSEEVENTF_LEFTDOWN | MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
        }
    }
"@

# Create an infinite loop to repeatedly perform the mouse click action
while ($true) {
    # Call the Click method of the Clicker class to simulate a mouse click
    [Clicker]::Click()

    # Pause the script execution for x seconds before the next iteration
    Start-Sleep -Seconds 5
}

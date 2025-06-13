import os
import glob
import subprocess
import time
import datetime
import tkinter as tk
from tkinter import ttk, scrolledtext, filedialog
import threading
import json

class WatchdogApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Watchdog Tracking UIPath Process")
        self.root.geometry("700x500")
        self.root.resizable(True, True)
        # Đặt icon với xử lý ngoại lệ và đường dẫn tương đối
        try:
            self.root.iconbitmap("WatchdogUiPath.ico")
        except Exception as e:
            print(f"Error setting icon: {e}. Using default icon.")
        self.is_running = False
        self.countdown_active = False
        self.countdown_seconds = 0
        self.countdown_end_time = 0

        # Configurations
        self.lock_file = ""
        self.input_json = ""
        self.uipath_exe = ""
        self.project_path_search = ""
        self.project_path = None
        self.max_retry = 3
        self.wait_seconds = 240
        self.wait_seconds_exit_file = 45
        self.retry_count = 0
        self.prev_filetime = None
        self.config_file = "config.json"

        # Custom colors
        self.bg_color = "#2E2E2E"
        self.fg_color = "#FFFFFF"
        self.accent_color = "#3498DB"
        self.error_color = "#E74C3C"

        # GUI Setup
        self.setup_gui()
        self.load_config()

    def setup_gui(self):
        """Set up the GUI with configuration options and countdown."""
        self.root.configure(bg=self.bg_color)

        # Config Frame
        config_frame = tk.Frame(self.root, bg=self.bg_color)
        config_frame.pack(fill=tk.X, pady=10)

        ttk.Label(config_frame, text="UiRobot.exe:", font=("Helvetica", 10), background=self.bg_color, foreground=self.fg_color).pack(side=tk.LEFT, padx=5)
        self.uipath_entry = ttk.Entry(config_frame, width=50)
        self.uipath_entry.pack(side=tk.LEFT, padx=5)
        ttk.Button(config_frame, text="Browse", command=self.browse_uipath).pack(side=tk.LEFT)

        config_frame2 = tk.Frame(self.root, bg=self.bg_color)
        config_frame2.pack(fill=tk.X, pady=5)

        ttk.Label(config_frame2, text="NUPKG Folder:", font=("Helvetica", 10), background=self.bg_color, foreground=self.fg_color).pack(side=tk.LEFT, padx=5)
        self.nupkg_entry = ttk.Entry(config_frame2, width=50)
        self.nupkg_entry.pack(side=tk.LEFT, padx=5)
        ttk.Button(config_frame2, text="Browse", command=self.browse_nupkg).pack(side=tk.LEFT)

        # Header Frame
        header_frame = tk.Frame(self.root, bg=self.bg_color)
        header_frame.pack(fill=tk.X, pady=10)

        tk.Label(
            header_frame,
            text="🔷 Watchdog Tracking UIPath Process 🔷",
            font=("Helvetica", 16, "bold"),
            fg=self.accent_color,
            bg=self.bg_color
        ).pack()

        self.status_label = tk.Label(
            header_frame,
            text="Status: Please configure paths",
            font=("Helvetica", 12),
            fg=self.fg_color,
            bg=self.bg_color
        )
        self.status_label.pack(pady=5)

        self.countdown_label = tk.Label(
            header_frame,
            text="",
            font=("Helvetica", 10),
            fg=self.accent_color,
            bg=self.bg_color
        )
        self.countdown_label.pack(pady=5)

        # Log Area
        log_frame = tk.Frame(self.root, bg=self.bg_color)
        log_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        self.log_area = scrolledtext.ScrolledText(
            log_frame,
            height=15,
            font=("Consolas", 10),
            wrap=tk.WORD,
            bg="#1C2526",
            fg=self.fg_color,
            insertbackground=self.fg_color
        )
        self.log_area.pack(fill=tk.BOTH, expand=True)
        self.log_area.config(state='disabled')

        # Button Frame
        button_frame = tk.Frame(self.root, bg=self.bg_color)
        button_frame.pack(fill=tk.X, pady=10)

        self.retry_label = tk.Label(
            button_frame,
            text=f"Retries: {self.retry_count}/{self.max_retry}",
            font=("Helvetica", 10),
            fg=self.fg_color,
            bg=self.bg_color
        )
        self.retry_label.pack(side=tk.LEFT, padx=10)

        self.start_button = ttk.Button(
            button_frame,
            text="Start Watchdog",
            command=self.start_watchdog,
            style="Accent.TButton"
        )
        self.start_button.pack(side=tk.LEFT, padx=10)

        self.stop_button = ttk.Button(
            button_frame,
            text="Stop Watchdog",
            command=self.stop,
            style="Danger.TButton",
            state="disabled"
        )
        self.stop_button.pack(side=tk.RIGHT, padx=10)

        # Configure ttk styles
        style = ttk.Style()
        style.configure("Accent.TButton", font=("Helvetica", 10), foreground=self.fg_color, background=self.accent_color)
        style.map("Accent.TButton", background=[("active", "#2980B9")])
        style.configure("Danger.TButton", font=("Helvetica", 10), foreground=self.fg_color, background=self.error_color)
        style.map("Danger.TButton", background=[("active", "#C0392B")])

    def load_config(self):
        """Load configuration from config.json."""
        if os.path.exists(self.config_file):
            try:
                with open(self.config_file, 'r', encoding='utf-8') as f:
                    config = json.load(f)
                    self.uipath_exe = config.get("uipath_exe", "")
                    self.project_path_search = config.get("project_path_search", "")
                    self.uipath_entry.delete(0, tk.END)
                    self.uipath_entry.insert(0, self.uipath_exe)
                    self.nupkg_entry.delete(0, tk.END)
                    self.nupkg_entry.insert(0, os.path.dirname(self.project_path_search.rstrip("*.nupkg")))
                    self.log("Loaded configuration from config.json")
            except Exception as e:
                self.log(f"Error loading config: {e}")

    def save_config(self):
        """Save configuration to config.json."""
        config = {
            "uipath_exe": self.uipath_exe,
            "project_path_search": self.project_path_search
        }
        try:
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(config, f, indent=4)
            self.log("Saved configuration to config.json")
        except Exception as e:
            self.log(f"Error saving config: {e}")

    def browse_uipath(self):
        """Browse for UiRobot.exe."""
        file_path = filedialog.askopenfilename(filetypes=[("Executable files", "*.exe")])
        if file_path:
            self.uipath_exe = file_path
            self.uipath_entry.delete(0, tk.END)
            self.uipath_entry.insert(0, file_path)
            self.save_config()

    def browse_nupkg(self):
        """Browse for folder containing .nupkg files."""
        folder_path = filedialog.askdirectory()
        if folder_path:
            self.project_path_search = os.path.join(folder_path, "*.nupkg")
            self.nupkg_entry.delete(0, tk.END)
            self.nupkg_entry.insert(0, folder_path)
            self.save_config()

    def log(self, message):
        """Append message to log area."""
        self.log_area.config(state='normal')
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.log_area.insert(tk.END, f"[{timestamp}] {message}\n")
        self.log_area.see(tk.END)
        self.log_area.config(state='disabled')
        self.root.update()

    def update_status(self, status):
        """Update status label and retries."""
        self.status_label.config(text=f"Status: {status}")
        self.retry_label.config(text=f"Retries: {self.retry_count}/{self.max_retry}")

    def start_countdown(self, seconds):
        """Start countdown timer."""
        self.countdown_seconds = seconds
        self.countdown_end_time = time.time() + seconds
        self.countdown_active = True
        self.update_countdown()

    def update_countdown(self):
        """Update countdown label every second."""
        if self.countdown_active and self.is_running:
            remaining = max(0, int(self.countdown_end_time - time.time()))
            self.countdown_label.config(text=f"Waiting {remaining} seconds...")
            if remaining > 0:
                self.root.after(1000, self.update_countdown)
            else:
                self.countdown_label.config(text="")
                self.countdown_active = False
        else:
            self.countdown_label.config(text="")
            self.countdown_active = False

    def wait_with_countdown(self, seconds):
        """Wait for specified seconds with countdown."""
        self.start_countdown(seconds)
        start_time = time.time()
        while self.is_running and (time.time() - start_time) < seconds:
            time.sleep(0.1)  # Small sleep to reduce CPU usage
        self.countdown_active = False
        self.countdown_label.config(text="")

    def start_watchdog(self):
        """Start the Watchdog process."""
        if not self.uipath_exe or not self.project_path_search:
            self.log("Please select UiRobot.exe and NUPKG folder.")
            self.update_status("Configuration incomplete")
            return
        self.lock_file = os.path.join(os.path.dirname(self.project_path_search.rstrip("*.nupkg")), "LogUiPath", "STATUS.lock")
        self.input_json = os.path.join(os.path.dirname(self.project_path_search.rstrip("*.nupkg")), "LogUiPath", "input.json")
        self.start_button.config(state="disabled")
        self.stop_button.config(state="normal")
        self.is_running = True
        self.log("Starting Watchdog...")
        threading.Thread(target=self.run_watchdog, daemon=True).start()

    def search_nupkg(self):
        """Search for .nupkg file."""
        self.log(f"Searching for .nupkg file in: {self.project_path_search}")
        self.update_status("Searching for .nupkg file...")
        nupkg_files = glob.glob(self.project_path_search)

        if not nupkg_files:
            self.log(f"No .nupkg files found in {self.project_path_search}")
            self.update_status("No .nupkg files found")
            self.stop()
            return False

        self.project_path = nupkg_files[-1]
        self.log(f"Found .nupkg file: {self.project_path}")
        self.log(f"Set nupkg project file is: {self.project_path}")
        return True

    def get_file_modtime(self):
        """Get modification time of lock file."""
        if os.path.exists(self.lock_file):
            mod_time = os.path.getmtime(self.lock_file)
            mod_time_str = datetime.datetime.fromtimestamp(mod_time).strftime("%Y-%m-%d %H:%M:%S")
            self.log(f"Checked modification time of STATUS.lock: {mod_time_str}")
            return mod_time_str
        return None

    def start_uipath(self):
        """Start UiPath process."""
        self.log("Starting UiPath process...")
        self.update_status("Starting UiPath...")
        try:
            subprocess.Popen([self.uipath_exe, "execute", "--file", self.project_path],
                             creationflags=subprocess.CREATE_NO_WINDOW)
            self.log("Completed starting UiPath process")
            self.update_status("UiPath running")
        except Exception as e:
            self.log(f"Error starting UiPath: {e}")
            self.update_status("Error starting UiPath")

    def terminate_uipath(self):
        """Terminate UiPath and related processes."""
        self.log("Terminating UiPath and Ksystem processes...")
        self.update_status("Terminating processes...")
        processes = ["UiPath.Studio.exe", "UiPath.Executor.exe", "UiPath.Agent.exe", "Angkor.Ylw.Main.MainWin45.exe"]
        for proc in processes:
            try:
                subprocess.run(["taskkill", "/f", "/im", proc], check=True, capture_output=True)
                self.log(f"Terminated {proc}")
            except subprocess.CalledProcessError:
                pass

    def restart_uipath(self):
        """Restart UiPath process."""
        if self.retry_count >= self.max_retry:
            self.log(f"Reached {self.max_retry} retries. Deleting input.json and stopping...")
            self.update_status("Max retries reached")
            self.wait_with_countdown(self.wait_seconds_exit_file)
            if os.path.exists(self.input_json):
                os.remove(self.input_json)
                self.log(f"Deleted {self.input_json}")
            self.log("Watchdog Stopped")
            self.stop()
            return False

        self.retry_count += 1
        self.log(f"Attempting restart #{self.retry_count}...")
        self.update_status(f"Restarting UiPath (Attempt {self.retry_count})")
        self.terminate_uipath()
        self.start_uipath()
        return True

    def run_watchdog(self):
        """Main Watchdog loop."""
        if not self.search_nupkg():
            return

        self.log("Watchdog initial complete")
        self.update_status("Watchdog Running")
        self.start_uipath()

        while self.is_running:
            self.log("Watchdog is running")
            self.update_status("Watchdog Running")
            self.log(f"Waiting {self.wait_seconds_exit_file} seconds for UiPath to initialize...")
            self.wait_with_countdown(self.wait_seconds_exit_file)

            if not self.is_running:
                break

            self.log(f"Checking file: {self.lock_file}")
            if not os.path.exists(self.lock_file):
                self.log("Lock file does not exist. Restarting UiPath...")
                self.update_status("Lock file missing, restarting...")
                if not self.restart_uipath():
                    break
                continue

            self.prev_filetime = self.get_file_modtime()
            self.log(f"Previous modification time: {self.prev_filetime}")

            self.log(f"Waiting {self.wait_seconds} seconds...")
            self.wait_with_countdown(self.wait_seconds)

            if not self.is_running:
                break

            if not os.path.exists(self.lock_file):
                self.log("Lock file was deleted. Restarting UiPath...")
                self.update_status("Lock file deleted, restarting...")
                if not self.restart_uipath():
                    break
                continue

            try:
                with open(self.lock_file, 'r', encoding='utf-8') as f:
                    status = f.readline().strip()
            except Exception as e:
                self.log(f"Error reading lock file: {e}")
                self.update_status("Error reading lock file")
                continue

            if status.lower() == "finish":
                self.log("UiPath process completed.")
                self.update_status("UiPath Completed")
                self.log("Watchdog Exiting")
                self.stop()
                break

            current_filetime = self.get_file_modtime()
            self.log(f"Current modification time: {current_filetime}")

            if current_filetime == self.prev_filetime:
                self.log("File not updated. Restarting UiPath...")
                self.update_status("File not updated, restarting...")
                if not self.restart_uipath():
                    break
                continue

            self.log("File updated. Process is running fine.")
            self.update_status("Process running fine")
            self.retry_count = 0

    def stop(self):
        """Stop the Watchdog and reset GUI."""
        self.is_running = False
        self.countdown_active = False
        self.countdown_label.config(text="")
        self.terminate_uipath()
        self.log("Watchdog stopped")
        self.update_status("Watchdog Stopped")
        self.start_button.config(state="normal")
        self.stop_button.config(state="disabled")
        self.retry_count = 0
        self.update_status("Ready to start")

if __name__ == "__main__":
    root = tk.Tk()
    app = WatchdogApp(root)
    root.mainloop()
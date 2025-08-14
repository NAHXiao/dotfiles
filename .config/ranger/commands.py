from ranger.api.commands import Command
import shutil

class safe_delete(Command):
    """
    :safe_delete

    Attempt to delete files using `gio` or `trash`.
    If both are unavailable or fail, ask to fallback to `rm -rf`.
    """

    def execute(self):
        self.files = [f.path for f in self.fm.thistab.get_selection()]
        if not self.files:
            self.fm.notify("No files selected.", bad=True)
            return

        if shutil.which("gio"):
            result = self.fm.execute_command(["gio", "trash"] + self.files, wait=True)
            if result and result.returncode == 0:
                return
            else:
                self.fm.ui.console.ask(
                    "`gio` failed to execute, use `rm` to delete? [y/n] ",
                    self._on_confirm_rm_gio,
                    ("y", "n")
                )
                return

        if shutil.which("trash"):
            result = self.fm.execute_command(["trash"] + self.files, wait=True)
            if result and result.returncode == 0:
                return
            else:
                self.fm.ui.console.ask(
                    "`trash` failed to execute, use `rm` to delete? [y/n] ",
                    self._on_confirm_rm_trash,
                    ("y", "n")
                )
                return

        self.fm.ui.console.ask(
            "`gio` and `trash` are both missing, use `rm` to delete? [y/n] ",
            self._on_confirm_rm_missing,
            ("y", "n")
        )

    def _delete_with_rm(self):
        self.fm.execute_command(["rm", "-rf"] + self.files, wait=True)
        self.fm.notify("Files deleted using rm.")

    def _on_confirm_rm_gio(self, answer):
        if answer == "y":
            self._delete_with_rm()
        else:
            self.fm.notify("Deletion cancelled.")

    def _on_confirm_rm_trash(self, answer):
        if answer == "y":
            self._delete_with_rm()
        else:
            self.fm.notify("Deletion cancelled.")

    def _on_confirm_rm_missing(self, answer):
        if answer == "y":
            self._delete_with_rm()
        else:
            self.fm.notify("Deletion cancelled.")

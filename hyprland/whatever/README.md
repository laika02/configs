# Firefox Pywal Files

Copied from current system for backup/migration:

- `pywalfox@frewacom.org.xpi`
  - Firefox extension package from the active profile.
- `pywalfox-native-host.json`
  - Native messaging host manifest used by Pywalfox.

Notes:
- Install `python-pywalfox` on the new system so the native host script path exists.
- After restoring and launching Firefox, re-enable/check the extension.

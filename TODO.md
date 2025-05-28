1. Automate TouchID auth for sudo

   In `/etc/pam.d/sudo`, at the top:

   ```
   auth       sufficient     pam_tid.so
   ```


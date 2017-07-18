
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(let ((compiled-config (concat user-emacs-directory "config.el")))
  (if (file-exists-p compiled-config)
      (load-file compiled-config)
    (require 'org)
    (find-file (concat user-emacs-directory "config.org"))
    (org-babel-tangle)
    (load-file compiled-config)
    (byte-compile-file compiled-config)))

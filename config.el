
(defvar mattly|config-location
  (expand-file-name (concat user-emacs-directory "config.org")))

(defun tangle-init ()
  "If the current buffer is 'init.org' the code-blocks are tangled, and the
  tangled file is compiled."
  (when (equal (buffer-file-name) mattly|config-location)
    ;; Avoid running hooks when tangling
    (let ((prog-mode-hook nil))
      (org-babel-tangle)
      (byte-compile-file (concat user-emacs-directory "config.el")))))

(add-hook 'after-save-hook 'tangle-init)

(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu" . "https://elpa.gnu.org/packages/")
        ("org"   . "http://orgmode.org/elpa/")))
(package-initialize)

(unless (package-installed-p 'use-package)
        (package-refresh-contents)
        (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(use-package try :ensure t)

(setq use-package-always-ensure t)

(use-package auto-package-update
  :config
  (setq auto-package-update-delete-old-versions t))

(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))
(prefer-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(setq-default buffer-file-coding-system 'utf-8)

(setq inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name
      inhibit-default-init t
      initial-major-mode 'text-mode
      initial-scratch-message "Welcome to mattlymacs")

(setq-default fill-column 80)  ; line-width for auto format, warnings, etc

(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file t)

(defvar mattlymacs-dir (expand-file-name user-emacs-directory)
  "The path to the emacs.d directory")

(defvar mattlymacs-local-dir (concat mattlymacs-dir ".local/")
  "Root directory for local Emacs files. Use this as storage for files that
   are safe to share across computers.")

(defvar mattlymacs-cache-dir (concat mattlymacs-dir "cache/")
  "Volatile storage. We can write a function to purge it. It shouldn't be in
  source control.")

(defvar mattlymacs-packages-dir (concat mattlymacs-dir "packages/")
  "Where package.el plugins are stored.")

(setq-default
 abbrev-file-name (concat mattlymacs-local-dir "abbrev.el")
 auto-save-list-file-name (concat mattlymacs-cache-dir "autosave")
 backup-directory-alist (list (cons "." (concat mattlymacs-cache-dir "backup/")))
 pcache-directory (concat mattlymacs-cache-dir "pcache/"))

(require 'cl-lib)

(defvar mattlymacs-init-hook nil
  "A list of hooks to run when initialized")

(defun mattly|initialize ()
  (run-hooks 'mattlymacs-init-hook))   

(add-hook 'emacs-startup-hook #'mattly|initialize)

(defun mattly|find-dotfile ()
  "Edit `init.org' int he current window"
  (interactive)
  (find-file-existing mattly|config-location))

(defun mattly|reload-init ()
  (interactive)
  (load-file "init.el")
  (mattly|initialize))

(use-package which-key
  :commands (which-key-mode)
  :diminish t
  :init (which-key-mode)
  :config
  (setq which-key-sort-order 'which-key-key-order-alpha
        which-key-idle-delay 0.25))

(use-package hydra)

(fset #'yes-or-no-p #'y-or-n-p) ; y/n instead of yes/no

(setq-default
 bidi-display-reordering nil ; disable bidirectional text for tiny performance boost
 blink-matching-paren nil    ; don't blink--too distracting
 cursor-in-non-selected-windows nil  ; hide cursors in other windows
 frame-inhibit-implied-resize t
 ;; remove continuation arrow on right fringe
 fringe-indicator-alist (delq (assq 'continuation fringe-indicator-alist)
                              fringe-indicator-alist)
 highlight-nonselected-windows nil
 indicate-buffer-boundaries nil
 indicate-empty-lines nil
 max-mini-window-height 0.3
 mode-line-default-help-echo nil ; disable mode-line mouseovers
 split-width-threshold nil       ; favor horizontal splits
 uniquify-buffer-name-style 'forward
 use-dialog-box nil              ; always avoid GUI
 visible-cursor nil
 x-stretch-cursor nil
 ;; defer jit font locking slightly to [try to] improve Emacs performance
 jit-lock-defer-time nil
 jit-lock-stealth-nice 0.1
 jit-lock-stealth-time 0.2
 jit-lock-stealth-verbose nil
 ;; `pos-tip' defaults
 pos-tip-internal-border-width 6
 pos-tip-border-width 1
 ;; no beeping or blinking please
 ring-bell-function #'ignore
 visible-bell nil)

(tooltip-mode -1) ; relegates tooltips to the echo area
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

(defconst IS-MAC   (eq system-type 'darwin))
(defconst IS-LINUX (eq system-type 'gnu/linux))

(when IS-MAC
  (setq mac-command-modifier 'meta
        mac-option-modifier 'alt)
  (when (require 'osx-clipboard nil t)))
    ;; (osx-clipboard-mode +1)))

(defvar mattly-font "Iosevka Light 14")
(set-face-attribute 'default nil :font mattly-font)
(set-frame-font mattly-font nil t)

(use-package zoom-frm
  :defer t
  :commands (zoom-in zoom-out zoom-in/out zoom-frm-unzoom))

(add-to-list 'custom-theme-load-path "/Users/mattly/projects/emacs/akkala-theme/")
(add-to-list 'load-path "/Users/mattly/projects/emacs/akkala-theme/")
(require 'akkala-themes)
(load-theme 'akkala-basic)

(use-package evil
  :demand t
  :init
  (setq evil-want-C-u-scroll t
        evil-want-visual-char-semi-exclusive t
        evil-want-Y-yank-to-eol t
        evil-magic t
        evil-echo-state t
        evil-indent-convert-tabs t
        evil-ex-search-vim-style-regexp t
        evil-ex-substitute-global t
        evil-ex-visual-char-range t
        evil-insert-skip-empty-lines t
        evil-mode-line-format 'nil
        evil-symbol-word-search t
        shift-select-mode nil)
  :config
  (evil-mode +1)
  (evil-select-search-module 'evil-search-module 'evil-search)
  (defun +evil*window-follow (&rest _)  (evil-window-down 1))
  (defun +evil*window-vfollow (&rest _) (evil-window-right 1))
  (advice-add #'evil-window-split  :after #'+evil*window-follow)
  (advice-add #'evil-window-vsplit :after #'+evil*window-vfollow))

(use-package general
  :commands (general-create-definer)
  :config
  (general-evil-setup t))

(general-create-definer bind-navigation
                        :keymaps '(evil-normal-state-map evil-visual-state-map evil-motion-state-map)) 
(general-create-definer bind-motion
                        :keymaps '(evil-motion-state-map)) 
(general-create-definer bind-operator
                        :keymaps '(evil-operator-state-map))
(general-create-definer bind-inner-object
                        :keymaps '(evil-inner-text-objects-map))
(general-create-definer bind-outer-object
                        :keymaps '(evil-outer-text-objects-map))

(general-create-definer bind-main-menu
                        :prefix "SPC"
                        :non-normal-prefix "M-S-SPC"
                        :keymaps 'global
                        :states '(normal visual operator insert emacs))

(general-create-definer bind-mode-menu
                        :prefix ","
                        :states '(normal visual))

(use-package evil-commentary
  :commands (evil-commentary evil-commentary-yank evil-commentary-line)
  :diminish t
  :config
  (evil-commentary-mode 1))

;; (setcdr evil-normal-state-map nil)
;; (setcdr evil-visual-state-map nil)
;; (setcdr evil-motion-state-map nil)
(setcdr evil-operator-state-map nil)

(use-package recentf
  :config
  (setq recentf-max-menu-items 0
        recentf-save-file (concat mattlymacs-cache-dir "recentf")
        recentf-max-saved-items 300
        recentf-exclude (list "^/tmp" "^/ssh:" "^/var/folders/.+$"
                              "\\.?ido\\.last$" "\\.revive$" "/TAGS$"))
  (recentf-mode 1))

(use-package counsel
  :diminish t
  :ensure t)

(use-package ivy
  :ensure t
  :diminish t
  :init (ivy-mode 1)
  :config
  (setq ivy-use-virtual-buffers t
        ivy-height 20
        ivy-count-format "(%d/%d) ")) 

(use-package all-the-icons-ivy
  :diminish t
  :config
  (all-the-icons-ivy-setup))

(use-package origami
  :diminish t
  :defer t
  :config
  (setq origami-show-fold-header t)
  (global-origami-mode))

(use-package smartparens
  :defer t
  :commands (sp-split-sexp sp-newline sp-up-sexp)
  :diminish t
  :init
  (setq sp-autowrap-region nil ; let others handle this
        sp-highlight-pair-overlay t
        sp-cancel-autoskip-on-backward-movement nil
        sp-show-pair-delay 0.2
        sp-show-pair-from-inside t)
  :config
  (require 'smartparens-config)
  (add-hook 'prog-mode-hook #'smartparens-mode)
  ;; sp interferes with replace-mode
  (add-hook 'evil-replace-state-entry-hook #'turn-off-smartparens-mode)
  (add-hook 'evil-replace-state-exit-hook #'turn-on-smartparens-mode)

  (sp-local-pair 'minibuffer-inactive-mode "'" nil :actions nil))

(setq-default indent-tabs-mode nil
              whitespace-mode nil
              require-final-newline nil)

(use-package ethan-wspace
  :defer t
  :diminish t
  :config
  (global-ethan-wspace-mode 1))



(use-package string-inflection
  :defer t
  :diminish t)

(use-package avy)

(use-package with-editor
  :defer t)

(bind-mode-menu
 :keymaps 'with-editor-mode-map
 "," '(with-editor-finish :which-key "finish")
 "a" '(with-editor-cancel :which-key "cancel")
 "c" '(with-editor-finish :which-key "finish")
 "k" '(with-editor-cancel :which-key "cancel"))

(use-package fill-column-indicator
  :defer t
  :commands (fci-mode))

(use-package restart-emacs
  :defer t)

(use-package projectile
  :demand t
  :diminish t
  :init
  (setq
   projectile-cache-file (concat mattlymacs-cache-dir "projectile.cache")
   projectile-completion-system 'ivy
   projectile-enable-caching (not noninteractive)
   projectile-globally-ignored-directories `(,mattlymacs-local-dir ".sync")
   projectile-globally-ignored-file-suffixes '(".elc")
   projectile-globally-ignored-files '(".DS_Store")
   projectile-indexing-method 'alien
   projectile-known-projects-file (concat mattlymacs-cache-dir "projectile.projects")
   projectile-project-root-files
   '(".git" ".hg" ".project" "package.json"))
  :config
  (add-hook 'mattlymacs-init-hook #'projectile-mode))

(use-package magit
  :commands (magit-status magit-list-repositories)
  :config
  (setq magit-display-buffer-function 'magit-display-buffer-fullframe-status-v1
        magit-completing-read-function 'ivy-completing-read))

(use-package evil-magit
  :init
  (with-eval-after-load 'magit
    (require 'evil-magit)))

(use-package git-commit
  :defer t
  :config
  (add-hook 'git-commit-mode-hook #'fci-mode))

(use-package gitattributes-mode
  :defer t)
(use-package gitconfig-mode
  :defer t)
(use-package gitignore-mode
  :defer t)

(use-package parinfer
  :ensure t
  :init
  (progn
    (setq parinfer-extensions
          '(defaults
             pretty-parens
             evil
             smart-yank))
    (add-hook 'emacs-lisp-mode-hook #'parinfer-mode)))

(use-package lispy)
(use-package evil-lispy)

(add-hook 'emacs-lisp-mode-hook #'evil-lispy-mode)

;; (define-key evil-operator-state-map "i" nil)
(bind-navigation
 "l" 'evil-backward-char
 "u" 'evil-previous-line
 "y" 'evil-forward-char

 "e" 'evil-next-line
 "n" 'evil-backward-word-begin
 "i" 'evil-forward-word-begin

 "L" 'back-to-indentation
 "U" 'evil-backward-paragraph
 "Y" 'evil-end-of-line

 "N" 'evil-backward-sentence-begin
 "I" 'evil-forward-sentence-begin
 "E" 'evil-forward-paragraph

 "j" 'evil-scroll-page-up
 "h" 'evil-scroll-page-down)

(define-key evil-operator-state-map "r" evil-inner-text-objects-map)
(define-key evil-operator-state-map "s" evil-outer-text-objects-map)

(bind-navigation
 "r" 'evil-insert
 "R" 'evil-insert-line
 "s" 'evil-append
 "S" 'evil-append-line
 "t" 'evil-change
 "T" 'evil-change-line
 "q" 'evil-replace
 "Q" 'evil-replace-state
 "z" 'evil-open-below
 "Z" 'evil-open-above

 "d" 'evil-delete
 "D" 'evil-delete-line

 "p" 'undo-tree-undo
 "P" 'undo-tree-redo

 "x" 'evil-delete-char
 "X" 'evil-delete-line
 "c" 'evil-yank
 "C" 'evil-yank-line
 "v" 'evil-paste-after
 "V" 'evil-paste-before)

(bind-navigation
 "TAB" '(origami-recursively-toggle-node :which-key "toggle this fold recursively (like org)")
 "/" '(swiper :which-key "swiper")
 "M-=" '(zoom-in :which-key "zoom in")
 "M--" '(zoom-out :which-key "zoom out")
 "M-x" '(counsel-M-x :which-key "counsel-M-x"))

(bind-main-menu
 "/" '(counsel-rg :which-key "search in current directory")
 "TAB" '(ivy-switch-buffer :which-key "ivy buffer")
 "SPC" '(counsel-M-x :which-key "M-x"))

(bind-main-menu
 :infix "b"
 "" '(:ignore t :which-key "buffer")
 "b" '(ivy-switch-buffer :which-key "switch")
 "d" '(evil-delete-buffer :which-key "delete")
 "D" '(kill-buffer-and-window :which-key "delete buffer & window"))

(bind-main-menu
 :infix "f"
 "" '(:ignore t :which-key "file")
 "D" '(delete-file :which-key "delete (any file)")
 "f" '(counsel-find-file :which-key "find file")
 "r" '(counsel-recentf :which-key "recent files")
 "R" '(rename-file :which-key "rename (any file)")
 "s" '(save-buffer :which-key "save"))

(bind-main-menu
 :infix "g"
 "" '(:ignore t :which-key "git")
 "b" '(magit-blame :which-key "blame")
 "f" '(counsel-git :which-key "find file")
 "g" '(counsel-git-grep :which-key "git grep")
 "s" '(magit-status :which-key "status"))

(bind-main-menu
 :infix "h"
 "" '(:ignore t :which-key "help")
 "f" '(counsel-describe-function :which-key "describe function")
 "F" '(counsel-describe-face :which-key "describe face")
 "k" '(describe-key :which-key "describe key")
 "v" '(counsel-describe-variable :which-key "describe variable"))

(bind-main-menu
 :infix "p"
 "" '(:ignore t :which-key "project")
 "b" '(projectile-switch-to-buffer :which-key "switch buffer")
 "f" '(projectile-find-file :which-key "find file")
 "p" '(projectile-switch-project :which-key "switch project")
 "r" '(projectile-recentf :which-key "recent files")
 "x" '(projectile-invalidate-cache :which-key "invalidate cache"))

(bind-main-menu
 :infix "q"
 "" '(:ignore t :which-key "quit")
 "r" '(restart-emacs :which-key "restart")
 "q" '(evil-save-and-quit :which-key "quit and save"))

(defhydra mattly-toggles (:color pink)
  "
_f_ fill column indicator:   %`fci-mode
_F_ auto line breaking:      %`auto-fill-function
_p_ smartparens:             %`smartparens-mode
_w_ whitespace display:      %`whitespace-mode
"
  ("f" fci-mode nil)
  ("F" auto-fill-mode nil)
  ("p" smartparens-mode nil)
  ("w" whitespace-mode nil)
  ("q" nil "cancel"))

(bind-main-menu
 "t" '(mattly-toggles/body :which-key "toggles"))

(bind-main-menu
 :infix "u"
 "-" '(zoom-out :which-key "zoom out")
 "=" '(zoom-in :which-key "zoom in")
 "0" '(zoom-frm-unzoom :which-key "zoom reset"))

(bind-main-menu
 :infix "w"
 "" '(:ignore t :which-key "window")
 "h" '(evil-window-left :which-key "go left")
 "j" '(evil-window-down :which-key "go down")
 "k" '(evil-window-up :which-key "go up")
 "l" '(evil-window-right :which-key "go right")
 "m" '(:ignore t :which-key "move")
 "m h" '(evil-window-move-far-left :which-key "far left")
 "m j" '(evil-window-move-very-bottom :which-key "far bottom")
 "m k" '(evil-window-move-very-top :which-key "far top")
 "m l" '(evil-window-move-far-right :which-key "far right")
 "s" '(evil-window-split :which-key "split left")
 "v" '(evil-window-vsplit :which-key "split below")
 "d" '(evil-window-delete :which-key "delete"))

(bind-main-menu
 :infix "x"
 "" '(:ignore t :which-key "text")
 "i" '(:ignore t :which-key "inflection")
 "i c" '(string-inflection-lower-camelcase :which-key "camelCase")
 "i C" '(string-inflection-camelcase :which-key "CamelCase")
 "i -" '(string-inflection-kebab-case :which-key "kebab-case")
 "i k" '(string-inflection-kebab-case :which-key "kebab-case")
 "i _" '(string-inflection-underscore :which-key "under_score") ;; you hate me
 "i u" '(string-inflection-underscore :which-key "under_score") ;; why do you hate me?
 "i U" '(string-inflection-upcase :which-key "UP_CASE")) ;; oh right you think `-` is math because you have a crap parser.

(defhydra mattly|folding (:color pink)
  "
Close^^          Open^^           Toggle^^        Goto^^
-----^^--------- ----^^---------- ------^^------- ----^^----
_c_: at point    _o_: at point    _a_: at point   _n_: next
_C_: recursively _O_: recursively _A_: all        _p_: previous
_m_: all         _r_: all         _TAB_: like org
"
  ("c" origami-close-node)
  ("C" origami-close-node-recursively)
  ("m" origami-close-all-nodes)
  ("o" origami-open-node)
  ("O" origami-open-node-recursively)
  ("a" origami-forward-toggle-node)
  ("r" origami-open-all-nodes)
  ("A" origami-toggle-all-nodes)
  ("TAB" origami-recursively-toggle-node)
  ("<tab>" origami-recursively-toggle-node)
  ("n" origami-next-fold)
  ("p" origami-previous-fold)
  ("q" nil :exit t)
  ("C-g" nil :exit t)
  ("<SPC>" nil :exit t))

(bind-main-menu
 "z" '(mattly|folding/body :which-key "folding"))

(bind-main-menu
 :infix "\\"
 "" '(:ignore t :which-key "config")
 "d" '(mattly|find-dotfile :which-key "find init.org")
 "p" '(auto-package-update-now :which-key "update packages")
 "r" '(mattly|reload-init :which-key "reload"))

(use-package org-plus-contrib
  :defer t
  :config
  (sp-with-modes '(org-mode)
    (sp-local-pair "\\[" "\\]" :post-handlers '(("|" "SPC")))
    (sp-local-pair "\\(" "\\)" :post-handlers '(("|" "SPC")))
    (sp-local-pair "$$" "$$" :post-handlers '((:add " | ")) :unless '(sp-point-at-bol-p))
    (sp-local-pair "{" nil)))

(use-package org-bullets
  :defer t
  :commands (org-bullets-mode)
  :init
  (setq org-bullets-bullet-list '("§" "𝟤" "𝟥" "𝟦" "𝟧" "𝟨" "𝟩" "𝟪" "𝟫"))
  (setq org-bullets-face-name 'org-bullet)
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(setq org-babel-load-languages '())
(defvar mattly|org-babel-load-languages
  '(emacs-lisp))

(defun +org|init-babel ()
  (setq org-src-fontify-natively t
        org-src-tab-acts-natively t
        org-src-window-setup 'other-window)

  (org-babel-do-load-languages
   'org-babel-load-languages
   (mapcar (lambda (sym) (cons sym t)) mattly|org-babel-load-languages))

  (add-hook 'org-src-mode-hook
            (lambda () (when header-line-format (setq header-line-format nil)))))

(add-hook 'org-mode-hook #'+org|init-babel)
(add-hook 'mattlymacs-init-hook #'+org|init-babel)

(use-package org-evil
  :defer t
  :diminish t
  :after org
  :config
  ;; (add-hook 'org-mode-hook 'evil-org-mode)
  (add-hook 'evil-org-mode-hook
      (lambda () (evil-org-set-key-theme))))

(general-define-key
 :states '(normal visual operator)
 :keymaps 'org-mode-map
 "RET" 'org-return-indent)

(bind-mode-menu
 :keymaps 'org-mode-map
 "c" '(org-edit-special :which-key "edit special")
 "d" '(org-insert-drawer :which-key "insert drawer")
 "h" '(org-insert-heading-respect-content :which-key "insert heading after")
 "H" '(org-insert-subheading :which-key "insert subheading here")
 "t" '(org-table-create :which-key "create table"))

(defhydra mattly|hydra-org-structure (:color pink)
  "
^Nav^               ^Subtree^          ^Node^
^^^^^^^^^-----------------------------------------------
_h_: up heading     _H_: promote       _N_: promote
_j_: next heading   _J_: move down     _P_: demote
_k_: prev heading   _K_: move up
_n_: next sibling   _L_: demote
_p_: prev sibling

"
  ("h" outline-up-heading)
  ("j" org-next-visible-heading)
  ("k" org-previous-visible-heading)
  ("n" org-forward-heading-same-level)
  ("p" org-backward-heading-same-level)
  ("H" org-promote-subtree)
  ("J" org-move-subtree-down)
  ("K" org-move-subtree-up)
  ("L" org-demote-subtree)
  ("N" org-do-promote)
  ("P" org-do-demote)
  ("q" nil "quit")
  ("ESC" nil "quit"))

(general-define-key
 :prefix "SPC"
 :states '(normal visual operator)
 :keymaps 'org-mode-map
 "k" '(mattly|hydra-org-structure/body :which-key "org structure"))

(general-define-key
 :prefix ","
 :states '(normal visual)
 :keymaps 'org-src-mode-map
 "c" '(org-edit-src-exit :which-key "save and exit")
 "k" '(org-edit-src-abort :which-key "abort and exit"))

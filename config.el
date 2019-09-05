;;;  -*- lexical-binding: t; -*-


;;
;; UI
(setq user-full-name    "Niklas Carlsson"
      user-mail-address "niklas.carlsson@posteo.net")

;; looks
(setq doom-modeline-height 40
      +doom-modeline-buffer-file-name-style 'relative-from-project
      doom-theme 'doom-dracula
      +workspaces-switch-project-function #'ignore)

;; prettify modes
(setq +pretty-code-enabled-modes '(emacs-lisp-mode org-mode))
(set-frame-parameter nil 'fullscreen 'maximized)

;; host os configuration
(load! "+functions")
(when (my/os-match "ARCH")
  (if (my/multi-screen-setup-p)
      (setq doom-font (font-spec :family "Roboto Mono" :size 14)
          doom-big-font (font-spec :family "Roboto Mono" :size 22)
          doom-variable-pitch-font (font-spec :family "Iosevka Term" :size 14))
    (setq doom-font (font-spec :family "Roboto Mono" :size 14)
            doom-big-font (font-spec :family "Roboto Mono" :size 36)
            doom-variable-pitch-font (font-spec :family "Iosevka Term" :size 14)))
  (font-put doom-font :weight 'semi-light)
  (setq x-super-keysym 'meta
        x-alt-keysym 'alt))
(when (my/os-match "Ubuntu")
    (setq doom-font (font-spec :family "Roboto Mono" :size 14)))
(when IS-MAC
  (setq ns-use-thin-smoothing t)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark))
               mac-option-modifier 'alt
               mac-command-modifier 'meta)


;;
;; Core Emacs

;; Show week numbers in calendar
(setq calendar-week-start-day 1
      calendar-intermonth-text
      '(propertize
        (format "%2d"
                (car
                 (calendar-iso-from-absolute
                  (calendar-absolute-from-gregorian (list month day year)))))
        'font-lock-face 'font-lock-function-name-face))

;; Don't bother
(setq confirm-kill-emacs nil)


;;
;; Mail
(setq send-mail-function 'sendmail-send-it
      message-send-mail-function 'message-send-mail-with-sendmail
      sendmail-program "msmtp")


;;
;; Screencast
(def-package! gif-screencast
  :defer t
  :config
  (with-eval-after-load 'gif-screencast
    (define-key gif-screencast-mode-map (kbd "<f12>") 'gif-screencast-toggle-pause)
    (define-key gif-screencast-mode-map (kbd "<f11>") 'gif-screencast-stop))
)

;; make window larger
(setq command-log-mode-window-size 60)


;;
;; Writing
(def-package! writeroom-mode
  :after org
  :init
  (setq writeroom-width 100)
  (add-hook 'writeroom-mode-hook #'my/writeroom)
  :config
  ;; create keybinding for toggling zen-writing
  (defun my/writeroom ()
    (interactive)
    (if writeroom-mode
        ;; enter
        (progn (git-gutter-mode -1)
               (visual-line-mode))
      ;; exit
      (progn (git-gutter-mode)
             (visual-line-mode -1))))
  (map! :localleader
        :map org-mode-map
        :desc "Toggle zen writing" :n "z" #'writeroom-mode))


;;
;; Remote editing
(with-eval-after-load 'tramp-sh
  ;; Create persistent connections
  (customize-set-variable
   'tramp-ssh-controlmaster-options
   (concat
    "-o ControlPath=/tmp/ssh-ControlPath-%%r@%%h:%%p "
    "-o ControlMaster=auto -o ControlPersist=yes"))
  (customize-set-variable 'tramp-use-ssh-controlmaster-options nil)
  ;; Add the remote host path
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)

  ;; solution for getting around a server with warning message about a not fully
  ;; functional terminal. This is due to the fact that tramp is set to "dumb"
  ;; Found a similar problem to mine here:
  ;; http://emacs.1067599.n8.nabble.com/problem-getting-files-under-SunOS-from-cygwin-td277890.html
  ;; there is also an example there about an interactive user input version if I ever need that :)
  (defconst my-tramp-press-return-prompt-regexp
    "\\(-  (press RETURN)\\)\\s-*"
    "Regular expression matching my login prompt request.")

  (defun my-tramp-press-return-action (proc vec)
    "Enter \"?\^M\" to send a carriage return."
    (save-window-excursion
      (message "%s" vec)
      (with-current-buffer (tramp-get-connection-buffer vec)
        (tramp-message vec 6 "\n%s" (buffer-string))
        ;; The control character for Enter is ^M
        ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Ctl_002dChar-Syntax.html#Ctl_002dChar-Syntax
        (tramp-send-string vec "?\^M"))))

  (add-to-list 'tramp-actions-before-shell
               '(my-tramp-press-return-prompt-regexp my-tramp-press-return-action)))


;; Let the scratch buffer have elisp major mode by default
;; if set to t it has the same mode as previous buffer
(setq doom-scratch-buffer-major-mode 'emacs-lisp-mode)

;;
;; Projects
(setq projectile-enable-caching nil
      projectile-project-search-path '("~/src/" "~/opensource"))


;;
;; Windows (not the operating system)
(after! org
  (set-popup-rule! "^\\*Org Agenda.*\\*$" :size 0.5 :side 'right :select t :ttl nil :autosave t)
  (set-popup-rule! "^CAPTURE.*\\.org$" :size 0.4 :side 'bottom :select t :autosave t))


;;
;; Proced
(set-popup-rule! "*Proced*" :size 0.4 :side 'bottom :select t :autosave t)


;;
;; Pass
(after! pass
  ;; enter evil mode
  (add-to-list 'evil-motion-state-modes 'pass-mode)
  ;; disable snipe to have access to those keys
  (push 'pass-mode evil-snipe-disabled-modes)
  ;; don't show the bindings
  (setq pass-show-keybindings nil)
  ;; define the looks
  (set-popup-rule! "*Password-Store*" :size 0.3 :side 'left :select t :autosave t)
  ;; Let's make the password shown directly
  (add-hook 'pass-view-mode-hook 'pass-view-toggle-password)

  ;;
  ;; Keybindings
  ;; Pass-mode
  (map!
   :map pass-mode-map
   :m "C-k" #'evil-window-up
   :m "C-j" #'evil-window-down
   :m "C-h" #'evil-window-left
   :m "C-l" #'evil-window-right
   (:desc "Copy" :prefix "y"
     :desc "Copy password" :m "y" #'pass-copy
     :desc "Copy field" :m "f" #'pass-copy-field
     :desc "Copy username" :m "u" #'pass-copy-username
     :desc "Copy username" :m "U" #'pass-copy-url)
   :desc "Insert" :m "i" #'pass-insert
   :desc "Insert generated" :m "I" #'pass-insert-generated
   :desc "Rename" :m "r" #'pass-rename
   :desc "Next entry" :m "j" #'pass-next-entry
   :desc "Previous entry" :m "k" #'pass-prev-entry
   (:desc "Extra keys" :prefix "g"
     :desc "Next directory" :m "j" #'pass-next-directory
     :desc "Previous directory" :m "k" #'pass-prev-directory
     :desc "Refresh" :m "r" #'pass-update-buffer)
   :desc "Open entry" :m "o" #'pass-view
   :desc "OTP options" :m "Options" #'pass-otp-options
   :desc "Delete entry" :m "d" #'pass-kill
   :desc "Go to entry" :m "f" #'pass-goto-entry)
  ;; Pass-view-mode
  (map! :localleader
        :map pass-view-mode-map
        :desc "Toggle password" :m "t" #'pass-view-toggle-password
        :desc "View qr-code" :m "Q" #'pass-view-qrcode
        :desc "Copy password" :m "y" #'pass-view-copy-password
        :desc "Quit" :m "q" #'pass-quit)
  ;; TODO: improve the pass-quit function to properly clean-up the window layout
  )


;;
;; Version control
;; spell check commit messages
(add-hook 'git-commit-setup-hook 'git-commit-turn-on-flyspell)
;; mitigate dumb terminals
(setenv "EDITOR" "emacsclient")
;; add submodules to magit-status
(with-eval-after-load 'magit
(magit-add-section-hook 'magit-status-sections-hook
                            'magit-insert-modules
                            'magit-insert-unpulled-from-upstream)
  (setq magit-module-sections-nested nil))
;; improve diff of org-mode files
(add-hook 'ediff-prepare-buffer-hook #'outline-show-all)


;;
;; Multi-language
;; automatic switch-back to English layout in normal mode
(let* ((normal-mode-keyboard-layout "us")
       (insert-mode-keyboard-layout normal-mode-keyboard-layout))
  ;; Add entry hook
  (add-hook 'evil-insert-state-entry-hook
            ;; switch language when entering insert mode to insert mode layout
            (lambda () (start-process "switch-to-previous-language" nil "xkb-switch" "-s" insert-mode-keyboard-layout)))
  ;; Add exit hook
  (add-hook 'evil-insert-state-exit-hook
            ;; save current insert mode layout and reset layout to English
            (lambda () (setq insert-mode-keyboard-layout (with-temp-buffer
                                                      (call-process "xkb-switch" nil t "-p")
                                                      (goto-char (point-min))
                                                      (string-trim-right (buffer-substring-no-properties (point) (line-end-position)))))
              (start-process "switch-to-normal" nil "xkb-switch" "-s" normal-mode-keyboard-layout))))



;;
;; Dired/Ranger
(after! ranger
  (map!
   (:map ranger-mode-map
     ;; Make it easier to move between windows
     "C-h" #'evil-window-left
     "C-l" #'evil-window-right
     "C-k" #'evil-window-up
     "C-j" #'evil-window-down
     ;; Batch rename files
     :m "r" #'find-name-dired
     ;; Goto project root
     :m ";g" (λ! () (find-file (projectile-project-root)))
     )))


;;
;; Flycheck
(add-hook 'text-mode-hook (lambda ()
                            (flycheck-mode -1)))
(add-hook 'org-mode-hook (lambda ()
                           (flycheck-mode -1)))


;;
;; Auto-formatting
;; (add-hook 'c++-mode-hook #'+format|enable-on-save)
(add-hook 'before-save-hook (lambda ()  (when (eq major-mode 'python-mode) (lsp-format-buffer))))
(setq show-trailing-whitespace nil)


;;
;; Documentation
;; right docsets for major-modes
(after! python
  (set-docsets! 'python-mode "Python 3" "NumPy" "SciPy" "Pandas"))
(after! dockerfile
  (set-docsets! 'dockerfile-mode "Docker"))
(after! cmake
  (set-docsets! 'cmake-mode "CMake"))
;; add archwiki to online providers
(add-to-list '+lookup-provider-url-alist '("ArchWiki" . "https://wiki.archlinux.org/index.php?search=%s"))


;;
;; Mode file association
(add-to-list 'auto-mode-alist '("\\.m\\'" . octave-mode))
(add-hook 'octave-mode-hook (lambda ()
                            (flycheck-mode -1)))
(add-to-list 'auto-mode-alist '("\\.MD\\'" . markdown-mode))


;;
;; Load other config files
(load! "+agenda")
(load! "+bindings")
(load! "+brain")
(load! "+debug")
(load! "+eshell")
(load! "+lsp")
(load! "+org")

;;   :config

;; -*- lexical-binding: t -*-
;; Mac specific setup
(when IS-MAC
  (setq ns-use-thin-smoothing t)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark))
               mac-option-modifier 'alt
               mac-command-modifier 'meta)

;; Just show the splash screen when switching project. Don't always want to
;; select a file
(setq-default +workspaces-switch-project-function #'ignore)
;; Arch setup
(if (string-match "ARCH"
         (with-temp-buffer (shell-command "uname -r" t)
                           (goto-char (point-max))
                           (delete-char -1)
                           (buffer-string)))
    (setq x-super-keysym 'meta
      x-alt-keysym 'alt))


;; General setup
(setq user-full-name    "Niklas Carlsson"
      user-mail-address "carlsson.niklas@gmail.com"

      +doom-modeline-buffer-file-name-style 'relative-from-project
      show-trailing-whitespace t
      ;; Don't ask when killing emacs
      confirm-kill-emacs nil
      )
;; tabs
;; Python try to guess tab-width but it assumes wrong width sometimes, turn it
;; off to make it more consistent. I always want 4 spaces for my tabs.
(setq python-indent-guess-indent-offset nil)
;; maximize first frame
(set-frame-parameter nil 'fullscreen 'maximized)


;; Load custom functions
(load! "+functions")
;; Load helm customization
(load! "+helm")


;; Unimpaired functions
(defun evil-unimpaired/insert-space-above (count)
  (interactive "p")
  (dotimes (_ count) (save-excursion (evil-insert-newline-above))))
(defun evil-unimpaired/insert-space-below (count)
  (interactive "p")
  (dotimes (_ count) (save-excursion (evil-insert-newline-below))))


;; Writeroom
(add-hook 'writeroom-mode-hook (lambda ()
                                 (progn
                                   (visual-line-mode 1)
                                   (hl-line-mode -1))))

;; TRAMP
;; make tramp assume ssh to avoid typing it when connecting to remote host
(setq tramp-default-method "ssh")


;; Ediff
(add-hook 'ediff-prepare-buffer-hook #'outline-show-all)


;; Command-log-mode
(setq command-log-mode-window-size 60)


;; Flyspell
;; this should be set to nil for performance
;; https://www.emacswiki.org/emacs/FlySpell
(setq flyspell-issue-message-flag nil)
;; aspell is the successor to ispell so let's use
(setq ispell-program-name "aspell")

;; Flycheck
;; disable using hooks
(add-hook 'text-mode-hook (lambda ()
                            (flycheck-mode -1)))
(add-hook 'org-mode-hook (lambda ()
                           (flycheck-mode -1)))


;; Elisp
;; prettify lambdas in elisp
(add-hook 'emacs-lisp-mode-hook #'prettify-symbols-mode)
;; Let the scratch buffer have elisp major mode by default
;; if set to t it has the same mode as previous buffer
(setq doom-scratch-buffer-major-mode 'emacs-lisp-mode)


;; Docker-Tramp
(require 'docker-tramp)

;; Screencast
(use-package gif-screencast
  :ensure t
  :config
  (with-eval-after-load 'gif-screencast
    (define-key gif-screencast-mode-map (kbd "<f12>") 'gif-screencast-toggle-pause)
    (define-key gif-screencast-mode-map (kbd "<f11>") 'gif-screencast-stop))
)


;; Org-mode
;; customize org-settings
(after! org
  (setq outline-blank-line nil)
  (setq org-cycle-separator-lines 2)
  (setq org-log-done 'time))
;; Turn of highlight line in org-mode
(add-hook 'org-mode-hook (lambda ()
                           (hl-line-mode -1)))
;; automatically redisplay images generated by babel
(add-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images)
;; place latex-captions below figures and tables
(setq org-latex-caption-above nil)
;; Enable eshell in babel blocks
(load! "+eshell")
;; Helm-rifle
(require 'helm-org-rifle)
;; Disable line-numbers in org-mode
(add-hook 'org-mode-hook #'doom|disable-line-numbers)
;; Agenda
;; specify the main org-directory
(setq org-directory "~/org")
;; set which directories agenda should look for todos
(setq org-agenda-files '("~/org"
                         "~/org/work"))


;; Org-Noter
(def-package! org-noter
  :config
  (map!
   (:leader
     (:prefix "n"
       :desc "Org-noter-insert" :n "i" #'org-noter-insert-note))))
;; Setup
(setq org-noter-always-create-frame nil
      org-noter-auto-save-last-location t)


;; Projectile
(setq projectile-enable-caching nil)


;; Hugo
(use-package ox-hugo
  :ensure t                      ;Auto-install the package from Melpa (optional)
  :after ox)


;; Pop-rule
(after! org
  (set-popup-rule! "^\\*Org Agenda.*\\*$" :size 0.5 :side 'right :vslot 1  :select t :quit t   :ttl nil :modeline nil :autosave t)
  (set-popup-rule! "^CAPTURE.*\\.org$"    :size 0.4 :side 'bottom          :select t                                  :autosave t))


;; Magit
;; automatic spellchecking in commit messages
(add-hook 'git-commit-setup-hook 'git-commit-turn-on-flyspell)
;; mitigate terminal is dumb
(setenv "EDITOR" "emacsclient")
;; submodules
(with-eval-after-load 'magit
(magit-add-section-hook 'magit-status-sections-hook
                            'magit-insert-modules
                            'magit-insert-unpulled-from-upstream)
  (setq magit-module-sections-nested nil))


;; Multi-Term
;; solve missing variables in terminal
(when IS-MAC
  (setenv "LC_CTYPE" "UTF-8")
  (setenv "LC_ALL" "en_US.UTF-8")
  (setenv "LANG" "en_US.UTF-8"))


;; Automatically switch back to English in normal mode
;; Set default normal/insert-mode language to English
(let* ((normal-mode-keyboard-layout "us")
       (insert-mode-keyboard-layout normal-mode-keyboard-layout))

  ;; Add entry hook
  (add-hook 'evil-insert-state-entry-hook
            ;; switch language when entering insert mode to insert mode layout
            (lambda () (quiet! (shell-command (concat "xkb-switch -s " insert-mode-keyboard-layout)))))

  ;; Add exit hook
  (add-hook 'evil-insert-state-exit-hook
            ;; save current insert mode layout and reset layouot to english
            (lambda () (setq insert-mode-keyboard-layout (shell-command-to-string "xkb-switch -p"))
              (quiet! (shell-command (concat "xkb-switch -s " normal-mode-keyboard-layout))))))

;; lsp
;; lsp-ui
(with-eval-after-load 'lsp-mode
  (setq lsp-ui-sideline-enable nil
        lsp-ui-sideline-ignore-duplicate t
        lsp-ui-doc-enable nil
        lsp-ui-doc-include-signature nil
        lsp-ui-doc-header nil))
;; company
;; (with-eval-after-load 'company-lsp
  ;; (setq company-lsp-enable-snippet t))
;; lsp-flycheck
(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-after-open-hook (lambda () (lsp-ui-flycheck-enable t)))
  (add-hook 'c-mode-common-hook 'flycheck-mode)) ;; Turn on flycheck for C++ buffers


;; GDB
;; Disable realgud safe prompt after command
(setq realgud-safe-mode nil)
;; Open debugging window style
(setq gdb-many-windows t)


;; Fill column indication
;; turn it off by default
(remove-hook! (text-mode prog-mode conf-mode) #'turn-on-fci-mode)

;; eshell
;; add fish-like autocompletion
(def-package! esh-autosuggest)
(add-hook 'eshell-mode-hook #'esh-autosuggest-mode)
;; utilize completion from fish
(when (and (executable-find "fish")
           (require 'fish-completion nil t))
  (global-fish-completion-mode))
;; fix pcomplete-completions-at-point uses a deprecated calling function
(add-hook 'eshell-mode-hook (lambda ()
                              (remove-hook 'completion-at-point-functions #'pcomplete-completions-at-point t)))
;; aliases
(after! eshell
  (set-eshell-alias!
   "ff"  "+ivy/projectile-find-file"
   "fd"  "counsel-projectile-find-dir"
   "/p" "+ivy/project-search"
   "/d" "+ivy/project-search-from-cwd"
   "d"   "deer $1"
   "l"   "ls -l"
   "la"  "ls -la"
   "gl"  "(call-interactively 'magit-log-current)"
   "gs"  "magit-status"
   "gc"  "magit-commit"
   "gbD" "my/git-branch-delete-regexp $1"
   "gbS" "my/git-branch-match $1"
   "rg"  "rg --color=always $*"))
;; Improvements from howard abrahams
;; programs that want to pause the output uses cat instead
(setenv "PAGER" "cat")


;; Dired
;; Make it possible to move files between two open Direds easily
(setq dired-dwim-target t)
;; Make it possible to edit permissions in wdired
;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Wdired.html
(after! wdired
  (setq wdired-allow-to-change-permissions t))
;; Override dired-mode so it uses deer
(add-hook! dired-mode #'ranger-override-dired-fn)


;; Snipe
(evil-snipe-override-mode 1)


;; Avy
;; Make avy operate on all visable windows
(setq avy-all-windows t)

;; Autoformat in C++ files using clang-format
(add-hook 'c++-mode-hook #'+format|enable-on-save)


;; org-caputre snippets
;; http://www.howardism.org/Technical/Emacs/capturing-content.html
(require 'which-func)

(defun my/org-capture-code-snippet (f)
  "Given a file, F, this captures the currently selected text
within an Org SRC block with a language based on the current mode
and a backlink to the function and the file."
  (with-current-buffer (find-buffer-visiting f)
    (let ((org-src-mode (replace-regexp-in-string "-mode" "" (format "%s" major-mode)))
          (func-name (which-function)))
      (my/org-capture-fileref-snippet f "SRC" org-src-mode func-name))))

(defun my/org-capture-fileref-snippet (f type headers func-name)
  (let* ((code-snippet
          (buffer-substring-no-properties (mark) (- (point) 1)))
         (file-name   (buffer-file-name))
         (file-base   (file-name-nondirectory file-name))
         (line-number (line-number-at-pos (region-beginning)))
         (initial-txt (if (null func-name)
                          (format "From [[file:%s::%s][%s]]:"
                                  file-name line-number file-base)
                        (format "From ~%s~ (in [[file:%s::%s][%s]]):"
                                func-name file-name line-number
                                file-base))))
    (format "
   %s

   #+BEGIN_%s %s
%s
   #+END_%s" initial-txt type headers code-snippet type)))
;; Hugo
;; Populates only the EXPORT_FILE_NAME property in the inserted headline.
(defun org-hugo-new-subtree-post-capture-template ()
  "Returns `org-capture' template string for new Hugo post.
See `org-capture-templates' for more information."
  (let* ((title (read-from-minibuffer "Post Title: ")) ;Prompt to enter the post title
         (fname (org-hugo-slug title)))
    (mapconcat #'identity
               `(
                 ,(concat "* TODO " title)
                 ":PROPERTIES:"
                 ,(concat ":EXPORT_FILE_NAME: " fname)
                 ":END:"
                 "%?\n")                ;Place the cursor here finally
               "\n")))


;; Org-capture
;; Personal snippets
;; Code snippet
(add-to-list 'org-capture-templates
             '("s" "Code snippet"  entry
               (file "~/org/code/snippets.org")
               "* %?\n%(my/org-capture-code-snippet \"%F\")"))
;; Work  capture templates
(add-to-list 'org-capture-templates
             '("w" "Work entries"))
(add-to-list 'org-capture-templates
             '("ws" "Code snippet"  entry
               (file "~/org/work/snippets.org")
               "* %?\n%(my/org-capture-code-snippet \"%F\")"))
(add-to-list 'org-capture-templates
  '("wt" "Todo" entry (file+headline "~/org/work/todo.org" "Inbox")
     "* [ ] %?\n%i" :prepend t :kill-buffer t))
(add-to-list 'org-capture-templates
              '("h"                ;`org-capture' binding + h
                "Hugo blog post"
                entry
                ;; It is assumed that below file is present in `org-directory'
                ;; and that it has a "Blog Ideas" heading. It can even be a
                ;; symlink pointing to the actual location of all-posts.org!
                (file+olp "todo.org" "Blog Ideas")
                (function org-hugo-new-subtree-post-capture-template)))

;; Org-babel
(defun src-block-in-session-p (&optional name)
  "Return if src-block is in a session of NAME.
NAME may be nil for unnamed sessions."
  (let* ((info (org-babel-get-src-block-info))
         (lang (nth 0 info))
         (body (nth 1 info))
         (params (nth 2 info))
         (session (cdr (assoc :session params))))

    (cond
     ;; unnamed session, both name and session are nil
     ((and (null session)
           (null name))
      t)
     ;; Matching name and session
     ((and
       (stringp name)
       (stringp session)
       (string= name session))
      t)
     ;; no match
     (t nil))))

(defun org-babel-restart-session-to-point (&optional arg)
  "Restart session up to the src-block in the current point.
Goes to beginning of buffer and executes each code block with
`org-babel-execute-src-block' that has the same language and
session as the current block. ARG has same meaning as in
`org-babel-execute-src-block'."
  (interactive "P")
  (unless (org-in-src-block-p)
    (error "You must be in a src-block to run this command"))
  (let* ((current-point (point-marker))
         (info (org-babel-get-src-block-info))
         (lang (nth 0 info))
         (params (nth 2 info))
         (session (cdr (assoc :session params))))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward org-babel-src-block-regexp nil t)
        ;; goto start of block
        (goto-char (match-beginning 0))
        (let* ((this-info (org-babel-get-src-block-info))
               (this-lang (nth 0 this-info))
               (this-params (nth 2 this-info))
               (this-session (cdr (assoc :session this-params))))
            (when
                (and
                 (< (point) (marker-position current-point))
                 (string= lang this-lang)
                 (src-block-in-session-p session))
              (org-babel-execute-src-block arg)))
        ;; move forward so we can find the next block
        (forward-line)))))

(defun org-babel-kill-session ()
  "Kill session for current code block."
  (interactive)
  (unless (org-in-src-block-p)
    (error "You must be in a src-block to run this command"))
  (save-window-excursion
    (org-babel-switch-to-session)
    (kill-buffer)))

(defun org-babel-remove-result-buffer ()
  "Remove results from every code block in buffer."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward org-babel-src-block-regexp nil t)
      (org-babel-remove-result))))


;; Matlab files (use octave mode)
(add-to-list 'auto-mode-alist '("\\.m\\'" . octave-mode))
(add-hook 'octave-mode-hook (lambda ()
                            (flycheck-mode -1)))


;; LaTeX export
(require 'ox-latex)
;; (add-to-list 'org-latex-packages-alist '("newfloat" "minted"))
(setq org-latex-listings 'minted)
;; set minted options
(setq org-latex-minted-options
        '(("frame" "lines")))
;; set pdf generation process
(setq org-latex-pdf-process
      '("xelatex -shell-escape -interaction nonstopmode %f"
        "xelatex -shell-escape -interaction nonstopmode %f"
        "xelatex -shell-escape -interaction nonstopmode %f"))
(add-to-list 'org-latex-minted-langs '(calc "mathematica"))
;; Add org-latex-class
(add-to-list 'org-latex-classes
             '("zarticle"
                   "\\documentclass[11pt,Wordstyle]{Zarticle}
                    \\usepackage[utf8]{inputenc}
                    \\usepackage{graphicx}
                        [NO-DEFAULT-PACKAGES]
                        [PACKAGES]
                        [EXTRA] "
                    ("\\section{%s}" . "\\section*{%s}")
                    ("\\subsection{%s}" . "\\subsection*{%s}")
                    ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                    ("\\paragraph{%s}" . "\\paragraph*{%s}")))


;;   :config

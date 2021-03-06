;;; ~/.config/doom/+x.el -*- lexical-binding: t; -*-

;;
;; Keyboard layout
;; Automatic switch-back to English layout in normal mode
;; Requires `xkb-switch' to be installed on remote machine if used via TRAMP.
(let* ((normal-mode-keyboard-layout "us")
       (insert-mode-keyboard-layout normal-mode-keyboard-layout))
  (when (executable-find "xkb\-switch")
    (add-hook 'evil-insert-state-entry-hook
              (lambda () (start-process "switch-to-previous-language" nil "xkb-switch" "-s" insert-mode-keyboard-layout)))
    (add-hook 'evil-insert-state-exit-hook
              (lambda () (setq insert-mode-keyboard-layout (with-temp-buffer
                                                        (call-process "xkb-switch" nil t "-p")
                                                        (goto-char (point-min))
                                                        (string-trim-right (buffer-substring-no-properties (point) (line-end-position)))))
                (start-process "switch-to-normal" nil "xkb-switch" "-s" normal-mode-keyboard-layout)))))

;;
;; Screencast
(use-package! gif-screencast
  :defer t
  :config
  (with-eval-after-load 'gif-screencast
    (define-key gif-screencast-mode-map (kbd "<f12>") 'gif-screencast-toggle-pause)
    (define-key gif-screencast-mode-map (kbd "<f11>") 'gif-screencast-stop)))


;;
;; Lock screen
(use-package! zone
  :defer t
  :config
  (map!
   :desc "Lock and run" :nvi "<f2>" '+zone/lock-screen))

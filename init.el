;;; package --- Summary: tory wheelwright's emacs config
;;; Commentary:
;;; Code:

(add-to-list 'load-path "~/.emacs.d/lisp")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; use `package` to install `use-package`, which will install everything else.

(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; package configurations

(use-package alchemist
  :ensure t)

(use-package auto-package-update
  :ensure t
  :config (setq auto-package-update-delete-old-versions t)
          (setq auto-package-update-hide-results t)
          (auto-package-update-maybe))

(use-package bracketed-paste
  :ensure t
  :config (bracketed-paste-enable))

(use-package company
  :ensure t)

(use-package editorconfig
  :ensure t
  :config (editorconfig-mode 1))

(use-package flycheck
  :ensure t
  :config (setq flycheck-clang-args (quote ("-std=c++17")))
          (setq flycheck-python-pylint-executable "python3")
          (setq flycheck-python-flake8-executable "python3")
          (setq flycheck-checker 'python-flake8)
          (flycheck-add-next-checker 'python-flake8 'python-pylint)
          (global-flycheck-mode))

(use-package flycheck-credo
  :init   (add-hook 'flycheck-mode-hook #'flycheck-credo-setup)
  :config (setq flycheck-elixir-credo-strict t))

(use-package flycheck-mix
  :ensure t
  :commands (flycheck-mix-setup))

(use-package helm
  :ensure t
  :config (helm-mode 1)
          (helm-autoresize-mode 1)
          (setq helm-split-window-inside-p 1)
  :bind   (("M-x" . helm-M-x)
            ("M-y" . helm-show-kill-ring)
            ("C-x b" . helm-mini)
            ("C-x C-f" . helm-find-files)
            ("C-x f" . helm-find-files)))

(use-package jedi
  :ensure t
  :hook   (python-mode . 'jedi:setup)
  :config (setq jedi:complete-on-dot t))

(use-package linum
  :config (global-linum-mode t)
          (setq linum-format "%3d| "))

(use-package rainbow-delimiters
  :ensure t
  :hook   (prog-mode . rainbow-delimiters-mode))

(use-package undo-tree
  :ensure t
  :config (global-undo-tree-mode))

;; language support
(use-package cython-mode     :ensure t)
(use-package dockerfile-mode :ensure t)
(use-package json-mode       :ensure t)
(use-package elixir-mode     :ensure t)
(use-package rust-mode       :ensure t)
(use-package yaml-mode       :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; low tech manual configuration

;; theme
(load-theme 'indoors t)

;; ui stuff

;; don't show startup screen in gui mode
(setq inhibit-startup-screen t)
;; show only column numbers along the bottom
(column-number-mode 1)
(line-number-mode 0)
;; make "yes/no" questions respond to "y/n"
(defalias 'yes-or-no-p 'y-or-n-p)
;; hide tool bar
(if (functionp 'tool-bar-mode) (tool-bar-mode 0))
;; hide menu bar
(menu-bar-mode 0)
;; can't remember what this does...i think it has to do with multiple frames
(add-hook 'server-switch-hook
  (lambda nil
    (let ((server-buf (current-buffer)))
      (bury-buffer)
      (switch-to-buffer-other-frame server-buf))))
(add-hook 'server-done-hook 'delete-frame)

;; set max line lenghts for various languages
(add-hook 'after-change-major-mode-hook
	  '(lambda () (when (eq major-mode 'rust-mode)
			(setq whitespace-line-column 99))))
(add-hook 'after-change-major-mode-hook
	  '(lambda () (when (eq major-mode 'c-mode)
			(setq whitespace-line-column 80))))
(add-hook 'after-change-major-mode-hook
	  '(lambda () (when (eq major-mode 'c++-mode)
			(setq whitespace-line-column 80))))
(add-hook 'after-change-major-mode-hook
	  '(lambda () (when (eq major-mode 'python-mode)
			(setq whitespace-line-column 79))))
(add-hook 'after-change-major-mode-hook
	  '(lambda () (when (eq major-mode 'java-mode)
(setq whitespace-line-column 100))))

;; editor stuff
(editorconfig-mode 1)
(defun smarter-move-beginning-of-line (arg)
  (interactive "^p")
  (setq arg (or arg 1))
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))
  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))
(global-set-key (kbd "C-a") 'smarter-move-beginning-of-line)
(defun rename-current-buffer-file ()
  (interactive)
  (let ((name (buffer-name))
	(filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
	(if (get-buffer new-name)
            (error "A buffer named '%s' already exists!" new-name)
	  (rename-file filename new-name 1)
	  (rename-buffer new-name)
	  (set-visited-file-name new-name)
	  (set-buffer-modified-p nil)
	  (message "File '%s' successfully renamed to '%s'"
		   name (file-name-nondirectory new-name)))))))
(global-set-key (kbd "C-x C-r") 'rename-current-buffer-file)
(defun delete-word (arg)
  (interactive "p")
  (delete-region (point) (progn (forward-word arg) (point))))
(defun backward-delete-word (arg)
  (interactive "p")
  (delete-word (- arg)))
(global-set-key (kbd "M-DEL") 'backward-delete-word)
(defun next-code-buffer ()
  (interactive)
  (let ((bread-crumb (buffer-name)))
    (next-buffer)
    (while
        (and
	 (string-match-p "^\*" (buffer-name))
	 (not (equal bread-crumb (buffer-name))))
      (next-buffer))))
(global-set-key [remap next-buffer] 'next-code-buffer)
(defun previous-code-buffer ()
  (interactive)
  (let ((bread-crumb (buffer-name)))
    (previous-buffer)
    (while
        (and
	 (string-match-p "^\*" (buffer-name))
	 (not (equal bread-crumb (buffer-name))))
      (previous-buffer))))
(global-set-key [remap previous-buffer] 'previous-code-buffer)
(global-unset-key (kbd "M-t"))
(global-set-key (kbd "C-x g") 'gdb)
(global-set-key (kbd "<f5>") 'compile-go)
(global-set-key (kbd "C-t") 'ansi-term)
(global-set-key [mouse-8] 'previous-buffer)
  (global-set-key [mouse-9] 'next-buffer)
(setq shift-select-mode nil)
(windmove-default-keybindings)
(setq whitespace-style '(face lines-tail))
(global-whitespace-mode)
(delete-selection-mode)
(global-undo-tree-mode)
(add-hook 'prog-mode-hook (lambda () (setq show-trailing-whitespace 1)))

;; c/++ stuff
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(c-set-offset 'innamespace 0) ;; Don't indent namespaces
(defadvice c-lineup-arglist (around my activate)
  "Improve indentation of continued C++11 lambda function opened as argument.
http://stackoverflow.com/a/23553882"
  (setq ad-return-value
    (if (and (equal major-mode 'c++-mode)
          (ignore-errors
            (save-excursion
              (goto-char (c-langelem-pos langelem))
              ;; Detect "[...](" or "[...]{". preceded by "," or "(",
              ;;   and with unclosed brace.
              (looking-at ".*[(,][ \t]*\\[[^]]*\\][ \t]*[({][^}]*$"))))
      0                             ; no additional indent
      ad-do-it)))                   ; default behavior)

;; company mode

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; this should probably be cleaned up to not use mode hooks to manipulate company-backends

(add-hook 'after-init-hook 'global-company-mode)
(setq company-idle-delay 0)
;;  (company-quickhelp-mode 1)
(add-hook 'darwin-system-type-hook
  (lambda ()
    (setq company-c-headers-path-system
      '("/usr/local/Cellar/gcc/6.2.0/include/c++/6.2.0"
         "/usr/local/Cellar/gcc/6.2.0/lib/gcc/6/gcc/x86_64-apple-darwin15.6.0/6.2.0/include"
         "/usr/local/Cellar/gcc/6.2.0/lib/gcc/6/gcc/x86_64-apple-darwin15.6.0/6.2.0/include-fixed"))))
(add-hook 'gnu/linux-system-type-hook
  (lambda ()
    (setq company-c-headers-path-system
      '("/usr/include/"
         "/usr/lib/gcc/x86_64-linux-gnu/4.9.3/include"
         "/usr/include/c++/4.9.3"))))
(setq company-tooltip-align-annotations t)

;;; init.el ends here

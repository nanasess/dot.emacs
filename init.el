;;; init.el --- Emacs initialization file.

;; Author: Kentaro Ohkouchi  <nanasess@fsm.ne.jp>
;; URL: git://github.com/nanasess/dot.emacs.git

;;; Code:


;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(setq gc-cons-threshold (* 128 1024 1024))
(when load-file-name
  (setq user-emacs-directory (file-name-directory load-file-name)))

(defvar user-initial-directory (locate-user-emacs-file "init.d/"))
(defvar user-site-lisp-directory (locate-user-emacs-file "site-lisp/"))
(defvar user-misc-directory (locate-user-emacs-file "etc/"))
(defvar user-bin-directory (locate-user-emacs-file "bin/"))
(defvar external-directory (expand-file-name "~/OneDrive - nanasess.net/emacs/"))

;; Silence the warning.
(defun el-get (&optional sync &rest packages))
(defun smartrep-define-key (keymap prefix alist))
(defun global-undo-tree-mode () ())
(defun quickrun-add-command (key alist))
(defun c-toggle-hungry-state (arg))
(defun php-completion-mode (arg))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; el-get settings
;;;

(add-to-list 'load-path (concat user-emacs-directory "el-get/ddskk"))
(add-to-list 'load-path (locate-user-emacs-file "el-get/el-get"))
(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(el-get-bundle tarao/el-get-lock)
(el-get-lock)

(el-get-bundle tarao/with-eval-after-load-feature-el)

;; (el-get 'sync 'esup)
;; (require 'esup)
(el-get-bundle awasira/cp5022x.el
  :name cp5022x
  :features cp5022x
  (with-eval-after-load-feature 'cp5022x
    (define-coding-system-alias 'iso-2022-jp 'cp50220)
    (define-coding-system-alias 'euc-jp 'cp51932)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; initial load files
;;;

(dolist (sys-type (list (symbol-name system-type)
			(symbol-name window-system)))

  (add-to-list 'load-path
	       (expand-file-name
		(concat user-initial-directory "arch/" sys-type)))
  (load "init" t))
(add-to-list 'load-path (expand-file-name user-initial-directory))
(add-to-list 'load-path (expand-file-name user-site-lisp-directory))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; exec-path settings
;;;

(dolist (dir (list "/sbin" "/usr/sbin" "/bin" "/usr/bin" "/usr/local/bin"
		   "/opt/local/sbin" "/opt/local/bin" "/usr/gnu/bin"
		   (expand-file-name "~/bin")
		   (expand-file-name "~/.emacs.d/bin")
		   (expand-file-name "~/Applications/UpTeX.app/teTeX/bin")))

  (when (and (file-exists-p dir) (not (member dir exec-path)))
    (setenv "PATH" (concat dir ":" (getenv "PATH")))
    (setq exec-path (append (list dir) exec-path))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Japanesed settings
;;;

(require 'japanese-init)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; SKK settings
;;;

(setq skk-user-directory (concat external-directory "ddskk")
      skk-init-file (concat user-initial-directory "skk-init.el")
      skk-isearch-start-mode 'latin
      skk-preload t)
(el-get-bundle ddskk)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; line-number settings
;;;

(line-number-mode 1)
(column-number-mode 1)
(size-indication-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; global key-bindings
;;;

(global-unset-key (kbd "C-M-t"))
(global-unset-key (kbd "C-z"))
(global-unset-key (kbd "C-\\"))
(global-set-key (kbd "M-g") 'goto-line)
(global-set-key (kbd "C-j") 'skk-mode)
(global-set-key (kbd "C-x C-j") 'skk-mode)
(global-set-key (kbd "C-t") 'other-window)
(global-set-key (kbd "C-z C-u") 'other-frame)
(global-set-key (kbd "C-z C-j") 'toggle-skk-kutouten)

(global-set-key (kbd "C-M-g") 'end-of-buffer)
(global-set-key (kbd "C-M-j") 'next-line)
(global-set-key (kbd "C-M-k") 'previous-line)
(global-set-key (kbd "C-M-h") 'backward-char)
(global-set-key (kbd "C-M-l") 'forward-char)
(setq dired-bind-jump nil)
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq enable-recursive-minibuffers t)
(setq cua-enable-cua-keys nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; backup files settings
;;;

(add-to-list 'backup-directory-alist (cons "\\.*$" (expand-file-name "~/.bak/")))
(setq delete-old-versions t
      make-backup-files t
      version-control t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; recentf settings
;;;

(el-get-bundle recentf-ext)
(setq recentf-max-saved-items 50000)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; coloring-region settings
;;;

(transient-mark-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; show-paren settings
;;;

(show-paren-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; show EOF settings
;;;

(setq eol-mnemonic-dos "(DOS)")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; face settings
;;;

;; (set-background-color "ivory")
;; (set-face-foreground 'font-lock-keyword-face "#7f007f")

(defface hlline-face
  '((((class color) (background light))
     (:background "Beige"))) nil :group 'font-lock-highlighting-faces)

(setq hl-line-face 'hlline-face)
(setq visible-bell t)
(setq whitespace-style
    '(spaces tabs newline space-mark tab-mark newline-mark))

(defface my-mark-whitespace '((t (:background "gray"))) nil
  :group 'font-lock-highlighting-faces)
(defface my-mark-tabs '((t (:background "Gainsboro"))) nil
  :group 'font-lock-highlighting-faces)
(defface my-mark-lineendsspaces '((t (:foreground "SteelBlue" :underline t))) nil
  :group 'font-lock-highlighting-faces)
(defvar my-mark-whitespace 'my-mark-whitespace)
(defvar my-mark-tabs 'my-mark-tabs)
(defvar my-mark-lineendsspaces 'my-mark-lineendsspaces)

(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
   major-mode
   '(("\t" 0 my-mark-tabs append)
     ("　" 0 my-mark-whitespace append)
     ("[ \t]+$" 0 my-mark-lineendsspaces append))))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)

(add-hook 'diff-mode-hook
	  #'(lambda ()
	      (set-face-bold-p 'diff-refine-change t)))

;; see also http://rubikitch.com/2015/05/14/global-hl-line-mode-timer/
(global-hl-line-mode 0)
(defun global-hl-line-timer-function ()
  (global-hl-line-unhighlight-all)
  (let ((global-hl-line-mode t))
    (global-hl-line-highlight)))
(setq global-hl-line-timer
      (run-with-idle-timer 0.1 t 'global-hl-line-timer-function))
;; (cancel-timer global-hl-line-timer)

;; use solarized.
(el-get-bundle solarized-emacs
  (load-theme 'solarized-light t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; window-system settings
;;;

(cond (window-system (tool-bar-mode 0)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; uniquify settings
;;;

(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)
(setq uniquify-ignore-buffers-re "*[^*]+*")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; dired-x settings
;;;

(add-hook 'dired-mode-hook
	  #'(lambda ()
	      (local-set-key (kbd "C-t") 'other-window)
	      (local-set-key (kbd "r") 'wdired-change-to-wdired-mode)))
(add-hook 'dired-load-hook
	  #'(lambda ()
	      (load "dired-x")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Indent settings
;;;

(setq-default indent-tabs-mode nil)
(defun basic-indent ()
  (setq tab-width 4)
  (setq indent-tabs-mode nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Misc settings
;;;

(setq indicate-empty-lines t)
(setq isearch-lax-whitespace nil)
(setq mouse-yank-at-point t)
(setq x-select-enable-clipboard t)
(setq x-select-enable-primary t)
(setq save-interprogram-paste-before-kill t)
(delete-selection-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Emacs lisp settings
;;;

(add-hook 'emacs-lisp-mode-hook
	  #'(lambda ()
	      (setq tab-width 8)
	      (setq indent-tabs-mode t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; CSS settings
;;;

(add-hook 'css-mode-hook 'basic-indent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Java settings
;;;

(add-hook 'java-mode-hook 'basic-indent)
(with-eval-after-load 'cc-mode
     (define-key java-mode-map [return] 'newline-and-indent))
(add-to-list 'auto-mode-alist
	     '("\\.\\(cls\\|trigger\\)\\'" . java-mode))
;; (require 'cedet)
;; (el-get 'sync 'malabar-mode)
;; (add-to-list 'auto-mode-alist '("\\.java\\'" . malabar-mode))
;; (setq semantic-default-submodes '(global-semantic-idle-scheduler-mode
;;                                   global-semanticdb-minor-mode
;;                                   global-semantic-idle-summary-mode
;;                                   global-semantic-mru-bookmark-mode))
;; (semantic-mode 1)
;; (add-hook 'malabar-mode-hook
;; 	  #'(lambda ()
;; 	      (add-hook 'after-save-hook 'malabar-compile-file-silently nil t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; JavaScript-mode settings
;;;

;; (add-hook 'javascript-mode-hook 'basic-indent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; js2-mode settings
;;;

(el-get-bundle js2-mode
  (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
  (add-hook 'js-mode-hook 'js2-minor-mode)
  (with-eval-after-load-feature 'js2-mode
    (setq js2-basic-offset 2
	  js2-bounce-indent-p t)
    (electric-indent-local-mode 0)
    (define-key js2-mode-map (kbd "RET") 'js2-line-break)
    (add-hook 'js2-mode-hook 'disabled-indent-tabs-mode)))

(defun disabled-indent-tabs-mode ()
  (set-variable 'indent-tabs-mode nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; tide settings
;;;

(el-get-bundle tide)
(el-get-bundle karma)
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  (company-mode +1))

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving
(add-hook 'before-save-hook 'tide-format-before-save)

(add-hook 'typescript-mode-hook #'setup-tide-mode)

;; format options
(setq tide-format-options '(:insertSpaceAfterFunctionKeywordForAnonymousFunctions t :placeOpenBraceOnNewLineForFunctions nil))
(add-hook 'js2-mode-hook #'setup-tide-mode)


;; (el-get 'sync 'jade-mode)
;; (require 'sws-mode)
;; (require 'jade-mode)
;; (add-to-list 'auto-mode-alist '("\\.styl$" . sws-mode))
;; (add-to-list 'auto-mode-alist '("\\.jade$" . jade-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; nXML-mode settings
;;;

(add-to-list 'auto-mode-alist
	     '("\\.\\(xml\\|xsl\\|rng\\)\\'" . nxml-mode))

(add-hook 'nxml-mode-hook
	  #'(lambda ()
	      (rng-validate-mode 0)
	      (set (make-local-variable 'auto-fill-mode) -1)
	      (set (make-local-variable 'nxml-slash-auto-complete-flag) t)
	      (set (make-local-variable 'nxml-child-indent) 2)
	      (set (make-local-variable 'indent-tabs-mode) nil)
	      (set (make-local-variable 'tab-width) 2)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; web-mode settings
;;;

(el-get-bundle! web-mode
  (setq web-mode-block-padding 4)
  (setq web-mode-enable-block-face t)
  (setq web-mode-script-padding 4)
  (setq web-mode-style-padding 4)
  (with-eval-after-load-feature 'web-mode
    (add-to-list 'auto-mode-alist '("\\.\\(twig\\|html\\)\\'" . web-mode))
    (add-hook 'web-mode-hook 'basic-indent)
    (add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
    (add-hook 'web-mode-hook
	      #'(lambda ()
		  (when (string-equal "tsx" (file-name-extension buffer-file-name))
		    (setup-tide-mode)
		    (karma-mode 1))))
    (add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode))
    (add-hook 'web-mode-hook
	      #'(lambda ()
		  (when (string-equal "jsx" (file-name-extension buffer-file-name))
		    (setup-tide-mode))))
    (add-to-list 'auto-mode-alist '("\\.\\(tpl\\)\\'" . web-mode))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; yaml-mode settings
;;;

(el-get-bundle! yaml-mode
  (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
  (add-hook 'yaml-mode-hook
	    #'(lambda ()
		(define-key yaml-mode-map "\C-m" 'newline-and-indent)
		(setq yaml-indent-offset 2))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; SQL settings
;;;

(setq sql-product 'postgres)
(add-hook 'sql-mode-hook 'basic-indent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; view-mode settings
;;;

(add-hook 'view-mode-hook
	  #'(lambda ()
	      (setq view-read-only t)
	      (auto-revert-mode 1)
	      (setq line-move-visual nil)))
(with-eval-after-load 'view
     (define-key view-mode-map (kbd "h") 'backward-word)
     (define-key view-mode-map (kbd "l") 'forward-word)
     (define-key view-mode-map (kbd "j") 'next-line)
     (define-key view-mode-map (kbd "k") 'previous-line)
     (define-key view-mode-map " " 'scroll-up)
     (define-key view-mode-map (kbd "b") 'scroll-down))
(add-to-list 'auto-mode-alist '("\\.log$" . view-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; frame-size settings
;;;

(defvar normal-frame-width 82)
(defvar wide-frame-width 175)
(defvar toggle-frame-flag t)

(defun frame-size-greater-p ()
  (< (+ (/ (- wide-frame-width normal-frame-width) 2) normal-frame-width)
     (frame-width (selected-frame))))

(defun normal-size-frame ()
  "Resize to normal size frame."
  (interactive)
  (setq toggle-frame-flag t)
  (set-frame-width (selected-frame) normal-frame-width))

(defun wide-size-frame ()
  "Resize to wide size frame."
  (interactive)
  (setq toggle-frame-flag nil)
  (set-frame-width (selected-frame) wide-frame-width))

(defun toggle-size-frame ()
  "toggle frame size."
  (interactive)
  (cond ((frame-size-greater-p) (normal-size-frame))
	((wide-size-frame))))

(defun toggle-fullscreen ()
  (interactive)
  (if (frame-parameter nil 'fullscreen)
      (set-frame-parameter nil 'fullscreen nil)
    (set-frame-parameter nil 'fullscreen 'fullscreen)))

(defun change-frame-height-up ()
  (interactive)
  (set-frame-height (selected-frame) (+ (frame-height (selected-frame)) 1)))
(defun change-frame-height-down ()
  (interactive)
  (set-frame-height (selected-frame) (- (frame-height (selected-frame)) 1)))
(defun change-frame-width-up ()
  (interactive)
  (set-frame-width (selected-frame) (+ (frame-width (selected-frame)) 1)))
(defun change-frame-width-down ()
  (interactive)
  (set-frame-width (selected-frame) (- (frame-width (selected-frame)) 1)))

(global-set-key (kbd "C-z C-a") 'toggle-fullscreen)
(global-set-key (kbd "C-z C-z") 'toggle-size-frame)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; migemo settings
;;;

(defvar migemo-dictionary
  (concat external-directory "migemo/dict/utf-8/migemo-dict"))
(when (file-exists-p migemo-dictionary)
  (setq migemo-command "cmigemo"
	migemo-options '("-q" "--emacs" "-i" "\a")
	migemo-user-dictionary nil
	migemo-regex-dictionary nil
	migemo-use-pattern-alist t
	migemo-use-frequent-pattern-alist t
	migemo-pattern-alist-length 10000
	migemo-coding-system 'utf-8-unix))
(el-get-bundle! migemo)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; goto-chg settings
;;;
;;; (auto-install-from-emacswiki "goto-chg.el")
;;;

(el-get-bundle goto-chg)
(global-set-key (kbd "C-.") 'goto-last-change)
(global-set-key (kbd "C-,") 'goto-last-change-reverse)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; point-undo settings
;;;
;;; (auto-install-from-emacswiki "point-undo.el")
;;;

;; (el-get 'sync 'point-undo)
;; (require 'point-undo)
;; (define-key global-map (kbd "C-M-,") 'point-undo)
;; (define-key global-map (kbd "C-M-.") 'point-redo)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; visual-regexp settings
;;;

(el-get-bundle visual-regexp)
(define-key global-map (kbd "M-%") 'vr/query-replace)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; easy-kill settings
;;;

(el-get-bundle! easy-kill in leoliu/easy-kill)
(global-set-key [remap kill-ring-save] 'easy-kill)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; org-mode settings
;;;

(setq org-directory (concat external-directory "howm/"))
(setq org-return-follows-link t)
(setq org-startup-folded nil)
(setq org-startup-truncated nil)

;;; org-html5presentation
;; (el-get 'sync 'org-html5presentation)

;;; org-tree-slide
;; http://pastelwill.jp/wiki/doku.php?id=emacs:org-tree-slide
;; (el-get 'sync 'org-tree-slide)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; htmlize settings
;;;

(el-get-bundle htmlize)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; session settings
;;;

(el-get-bundle! session)
(add-hook 'after-init-hook 'session-initialize)
(setq session-save-print-spec '(t nil 40000))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; cua-mode settings
;;;

(if (not (version< "24.3.99" emacs-version))
    (cua-mode t)
  (setq cua-enable-cua-keys nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; expand-region settings
;;;

(el-get-bundle expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)

(el-get-bundle multiple-cursors)
(el-get-bundle smartrep)

(global-set-key (kbd "<C-M-return>") 'mc/edit-lines)
(smartrep-define-key
    global-map "C-z" '(("C-n" . 'mc/mark-next-like-this)
		       ("C-p" . 'mc/mark-previous-like-this)
		       ("*"   . 'mc/mark-all-like-this)))

;; see https://github.com/magnars/expand-region.el/issues/220
(setq shift-select-mode nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; vc-svn settings
;;;

(add-to-list 'process-coding-system-alist '("svn" . utf-8))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; psvn settings
;;;

(el-get-bundle dsvn)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; magit settings
;;;

(el-get-bundle magit)
(add-to-list 'load-path (concat user-emacs-directory "el-get/magit/lisp"))
(require 'magit)
(require 'magit-blame)

(setq magit-diff-refine-hunk t)

(global-set-key (kbd "C-z m") 'magit-status)
(define-key magit-log-mode-map (kbd "j") 'magit-section-forward)
(define-key magit-log-mode-map (kbd "k") 'magit-section-backward)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; howm settings
;;;

(defvar howm-menu-lang 'ja)
;; (defvar howm-directory org-directory)
(defvar howm-directory (concat external-directory "howm/"))
(defvar howm-file-name-format "%Y/%m/%Y-%m-%d-%H%M%S.txt")
(defvar howm-history-file (concat howm-directory ".howm-history"))
(defvar howm-keyword-file (concat howm-directory ".howm-keys"))
(defvar howm-menu-schedule-days-before 30)
(defvar howm-menu-schedule-days 30)
(defvar howm-menu-expiry-hours 2)
(defvar howm-menu-refresh-after-save nil)
(defvar howm-refresh-after-save nil)
(defvar howm-list-all-title t)
(defvar howm-schedule-menu-types "[!@\+]")
(add-hook 'markdown-mode-hook 'howm-mode)
(add-hook 'org-mode-hook 'howm-mode)
(defvar howm-view-title-header "Title:")
(setq howm-view-use-grep t)
;; see http://blechmusik.hatenablog.jp/entry/2013/07/09/015124
(setq howm-process-coding-system 'utf-8-unix)
(setq howm-todo-menu-types "[-+~!]")
(el-get-bundle! howm
  :type git
  :url "git://git.osdn.jp/gitroot/howm/howm.git"
  :build `(("./configure" ,(concat "--with-emacs=" el-get-emacs)) ("make")))
(add-to-list 'auto-mode-alist '("\\.txt$" . gfm-mode))
(setq howm-template
      (concat howm-view-title-header
	      (concat
	       " %title%cursor\n"
	       "Date: %date\n\n"
	       "%file\n\n")
	      (concat
	       "<!--\n"
	       "  Local Variables:\n"
	       "  mode: gfm\n"
	       "  coding: utf-8-unix\n"
	       "  End:\n"
	       "-->\n")))
(defun howm-save-and-kill-buffer ()
  "kill screen when exiting from howm-mode"
  (interactive)
  (let* ((file-name (buffer-file-name)))
    (when (and file-name (string-match "\\.txt" file-name))
      (if (save-excursion
            (goto-char (point-min))
            (re-search-forward "[^ \t\r\n]" nil t))
          (howm-save-buffer)
        (set-buffer-modified-p nil)
        (when (file-exists-p file-name)
          (delete-file file-name)
          (message "(Deleted %s)" (file-name-nondirectory file-name))))
      (kill-buffer nil))))
(add-hook 'howm-mode-hook
	  #'(lambda ()
	      (define-key howm-mode-map (kbd "C-c C-q") 'howm-save-and-kill-buffer)))

(global-set-key (kbd "C-z c") 'howm-create)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; quickrun.el settings
;;;

(el-get-bundle quickrun
  (with-eval-after-load-feature 'quickrun
    (add-to-list
     'quickrun-file-alist
     '("\\(Test\\.php\\|TestSuite\\.php\\|AllTests\\.php\\)\\'" . "phpunit"))))

(defface phpunit-pass
  '((t (:foreground "white" :background "green" :weight bold))) nil
  :group 'font-lock-highlighting-faces)
(defface phpunit-fail
  '((t (:foreground "white" :background "red" :weight bold))) nil
  :group 'font-lock-highlighting-faces)

(defun quickrun/phpunit-outputter ()
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "" nil t)
      (replace-match "" nil nil)))
  (highlight-phrase "^OK.*$" 'phpunit-pass)
  (highlight-phrase "^FAILURES.*$" 'phpunit-fail))

(quickrun-add-command "phpunit" '((:command . "phpunit")
                                  (:exec . "%c %s")
                                  (:outputter . quickrun/phpunit-outputter)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; auto-complete.el settings
;;;

(el-get-bundle auto-complete)
(auto-complete-mode 0)
(global-auto-complete-mode 0)
;; (require 'auto-complete-config)
;; (add-to-list 'ac-dictionary-directories
;; 	     (expand-file-name
;; 	      (concat user-site-lisp-directory "auto-complete/dict")))
;; ;; (ac-config-default)
;; (setq ac-delay 0.3)
;; (setq ac-auto-show-menu 0.8)
;; (setq ac-use-menu-map t)
;; (define-key ac-completing-map [tab] 'ac-complete)
;; (define-key ac-completing-map [return] 'ac-complete)

(el-get-bundle company-mode
  (global-company-mode 1)
  (global-set-key (kbd "C-M-i") 'company-complete)
  (with-eval-after-load-feature 'company
    (setq company-idle-delay 0
	  company-minimum-prefix-length 2
	  company-selection-wrap-around t)
    (define-key company-active-map (kbd "C-n") 'company-select-next)
    (define-key company-active-map (kbd "C-p") 'company-select-previous)
    (define-key company-search-map (kbd "C-n") 'company-select-next)
    (define-key company-search-map (kbd "C-p") 'company-select-previous)

    ;; C-sで絞り込む
    (define-key company-active-map (kbd "C-s") 'company-filter-candidates)

    ;; TABで候補を設定
    (define-key company-active-map (kbd "C-i") 'company-complete-selection)

    ;; 各種メジャーモードでも C-M-iで company-modeの補完を使う
    (define-key emacs-lisp-mode-map (kbd "C-M-i") 'company-complete)

    (set-face-attribute 'company-tooltip nil
			:foreground "black" :background "lightgrey")
    (set-face-attribute 'company-tooltip-common nil
			:foreground "black" :background "lightgrey")
    (set-face-attribute 'company-tooltip-common-selection nil
			:foreground "white" :background "steelblue")
    (set-face-attribute 'company-tooltip-selection nil
			:foreground "black" :background "steelblue")
    (set-face-attribute 'company-preview-common nil
			:background nil :foreground "lightgrey" :underline t)
    (set-face-attribute 'company-scrollbar-fg nil
			:background "orange")
    (set-face-attribute 'company-scrollbar-bg nil
			:background "gray40")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; PHP settings
;;;

(el-get-bundle php-mode
 (with-eval-after-load-feature 'php-mode
   (setq php-manual-url "http://jp2.php.net/manual/ja/"
	 php-mode-coding-style 'symfony2
	 php-search-url "http://jp2.php.net/")
   (add-to-list 'load-path
		(concat user-emacs-directory "el-get/php-mode/skeleton"))
   (require 'php-ext)
   (define-key php-mode-map (kbd "M-.") 'ac-php-find-symbol-at-point)
   (define-key php-mode-map [return] 'newline-and-indent)
   (define-key php-mode-map (kbd "C-z C-t") 'quickrun)
   (add-to-list 'auto-mode-alist '("\\.\\(inc\\|php[s34]?\\)$" . php-mode))
   (add-hook 'php-mode-hook 'php-c-style)))

;; (el-get 'sync 'smartparens)

;; require github.com/vim-php/phpctags
;; require php >=5.5
;; require cscope >= 15.8a
;; M-x ac-php-remake-tags-all
(el-get-bundle ac-php)

(defun php-c-style ()
  (interactive)
  (auto-complete-mode 0)
  (require 'ac-php)
  (require 'company-php)
  ;; (setq ac-sources '(ac-source-php ac-source-abbrev ac-source-dictionary ac-source-words-in-same-mode-buffers))
  (company-mode t)
  (ac-php-core-eldoc-setup)
  (make-local-variable 'company-backends)
  (add-to-list 'company-backends 'company-ac-php-backend)
  (electric-indent-local-mode t)
  (electric-layout-mode t)
  (electric-pair-local-mode t)
  (flycheck-mode t)
  (set (make-local-variable 'comment-start) "// ")
  (set (make-local-variable 'comment-start-skip) "// *")
  (set (make-local-variable 'comment-end) "")
  (setq flycheck-phpcs-standard "PSR2")
  (setq flycheck-phpmd-rulesets (concat user-emacs-directory "phpmd_ruleset.xml")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; markdown-mode settings
;;;

(el-get-bundle markdown-mode)
(add-to-list 'auto-mode-alist '("\\.\\(markdown\\|md\\)\\'" . gfm-mode))

;; see also http://stackoverflow.com/questions/14275122/editing-markdown-pipe-tables-in-emacs
(defun cleanup-org-tables ()
  (save-excursion
    (goto-char (point-min))
    (while (search-forward "-+-" nil t) (replace-match "-|-"))))

(add-hook 'markdown-mode-hook 'turn-on-orgtbl)
(add-hook 'markdown-mode-hook
          #'(lambda()
	      (add-hook 'after-save-hook 'cleanup-org-tables  nil 'make-it-local)))
(add-hook 'gfm-mode-hook 'turn-on-orgtbl)
(add-hook 'gfm-mode-hook
          #'(lambda()
	      (add-hook 'after-save-hook 'cleanup-org-tables  nil 'make-it-local)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; csv-mode settings
;;;

(el-get-bundle csv-mode in emacsmirror/csv-mode)
(add-to-list 'auto-mode-alist '("\\.[Cc][Ss][Vv]\\'" . csv-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; csharp
;;;

(el-get-bundle shut-up in cask/shut-up)
(el-get-bundle omnisharp-mode
  :depends (csharp-mode shut-up dash s f))
;; (el-get-bundle company)
;; (el-get-bundle ac-company)
;; (eval-after-load 'company
;;   '(add-to-list 'company-backends 'company-omnisharp))
;;
;; git clone git@github.com:OmniSharp/omnisharp-roslyn.git
;; cd omnisharp-roslyn
;; ./build.sh
;;
;; XXX OmniSharp-Roslyn が自動起動してくれないので 以下のようにして手動で起動させる
;; ~/git-repos/omnisharp-roslyn/artifacts/publish/OmniSharp/default/netcoreapp1.1/OmniSharp -s `pwd`
;;
;; さらに csharp-mode や omnisharp-mode がちゃんと起動しない場合は以下のように手動で起動させる
;; M-x my-csharp-mode-hook
;; M-x my-omnisharp-mode-hook
(setq omnisharp-server-executable-path "~/bin/omnisharp-osx/run")
;; (require 'ac-company)
;; (ac-company-define-source ac-source-company-omnisharp company-omnisharp)

;; (setq omnisharp-debug 1)


;; see https://github.com/nosami/omnisharp-demo/blob/master/config/omnisharp.el
(defun csharp-newline-and-indent ()
  "Open a newline and indent.If point is between a pair of braces, opens newlines to put braces
on their own line."
  (interactive)
  (save-excursion
    (save-match-data
      (when (and
             (looking-at " *}")
             (save-match-data
               (when (looking-back "{ *")
                 (goto-char (match-beginning 0))
                 (unless (looking-back "^[[:space:]]*")
                   (newline-and-indent))
                 t)))
        (unless (and (boundp electric-pair-open-newline-between-pairs)
                     electric-pair-open-newline-between-pairs
                     electric-pair-mode)
          (goto-char (match-beginning 0))
          (newline-and-indent)))))
  (newline-and-indent))
(defun omnisharp-format-before-save ()
  "Before save hook to format the buffer before each save."
  (interactive)
  (when (bound-and-true-p omnisharp-mode)
    (omnisharp-code-format)))
(defun my-csharp-mode-hook ()
  (interactive)
  (flycheck-mode 1)
  ;; (auto-complete-mode 1)
  (electric-pair-local-mode 1) ;; for Emacs25
  (setq flycheck-idle-change-delay 2)
  (omnisharp-mode 1))
(defun my-omnisharp-mode-hook ()
  (interactive)
  (message "omnisharp-mode enabled")
  ;; (define-key omnisharp-mode-map "\C-c\C-s" 'omnisharp-start-omnisharp-server)
  ;; (define-key company-active-map (kbd ".") (lambda() (interactive) (company-complete-selection-insert-key-and-complete '".")))
  (define-key company-active-map (kbd "]") (lambda() (interactive) (company-complete-selection-insert-key-and-complete '"]")))
  (define-key company-active-map (kbd "[") (lambda() (interactive) (company-complete-selection-insert-key '"[")))
  (define-key company-active-map (kbd ")") (lambda() (interactive) (company-complete-selection-insert-key '")")))
  (define-key company-active-map (kbd "<SPC>") nil)
  (define-key company-active-map (kbd ";") (lambda() (interactive) (company-complete-selection-insert-key '";")))
  (define-key company-active-map (kbd ">") (lambda() (interactive) (company-complete-selection-insert-key '">")))
  (define-key omnisharp-mode-map (kbd "}") 'csharp-indent-function-on-closing-brace) 
  (define-key omnisharp-mode-map "\M-/"     'omnisharp-auto-complete)
  (define-key omnisharp-mode-map "."        'omnisharp-add-dot-and-auto-complete)
  (define-key omnisharp-mode-map "\C-c\C-c" 'omnisharp-code-format)
  (define-key omnisharp-mode-map "\C-c\C-N" 'omnisharp-navigate-to-solution-member)
  (define-key omnisharp-mode-map "\C-c\C-n" 'omnisharp-navigate-to-current-file-member)
  (define-key omnisharp-mode-map "\C-c\C-f" 'omnisharp-navigate-to-solution-file)
  (define-key omnisharp-mode-map "\M-."     'omnisharp-go-to-definition)
  (define-key omnisharp-mode-map "\C-c\C-r" 'omnisharp-rename)
  (define-key omnisharp-mode-map "\C-c\C-v" 'omnisharp-run-code-action-refactoring)
  (define-key omnisharp-mode-map "\C-c\C-o" 'omnisharp-auto-complete-overrides)
  (define-key omnisharp-mode-map "\C-c\C-u" 'omnisharp-fix-usings)
  (define-key omnisharp-mode-map (kbd "<RET>") 'csharp-newline-and-indent)

  (add-to-list 'company-backends 'company-omnisharp)
  ;; (define-key omnisharp-mode-map "\C-c\C-t\C-s" (lambda() (interactive) (omnisharp-unit-test "single")))
  ;; (define-key omnisharp-mode-map "\C-c\C-t\C-r" (lambda() (interactive) (omnisharp-unit-test "fixture")))
  ;; (define-key omnisharp-mode-map "\C-c\C-t\C-e" (lambda() (interactive) (omnisharp-unit-test "all")))
  )
(setq omnisharp-company-strip-trailing-brackets nil)
(add-hook 'csharp-mode-hook 'my-csharp-mode-hook)
(add-hook 'csharp-mode-hook
	  #'(lambda ()
	      ;; (add-to-list 'ac-sources 'ac-source-omnisharp)
	      (add-to-list 'flycheck-checkers 'csharp-omnisharp-codecheck)))
(add-hook 'omnisharp-mode-hook 'my-omnisharp-mode-hook)

;; (add-hook 'before-save-hook 'omnisharp-format-before-save)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; yafolding settings
;;;

;; (el-get-bundle yafolding)
;; (add-hook 'prog-mode-hook 'yafolding-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; mew settings
;;;

(el-get-bundle mew)
;; mm-version
(require 'mm-version)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; twitting-mode settings
;;;

(el-get-bundle twittering-mode
  (setq
   twittering-allow-insecure-server-cert nil
   twittering-auth-method 'oauth
   twittering-bitly-login twittering-username
   twittering-display-remaining t
   twittering-retweet-format "RT @%s: %t"
   twittering-status-format
   (concat "%i %S(%s),  %@:
%" "FILL[  ]{%T // from %f%L%r%R}
 ")
   twittering-tinyurl-service 'j.mp
   twittering-username "nanasess")
  (with-eval-after-load-feature 'twittering-mode
    (define-key twittering-mode-map
      (kbd "s") 'twittering-current-timeline)
    (define-key twittering-mode-map
      (kbd "w") 'twittering-update-status-interactive)
    (define-key twittering-edit-mode-map
      (kbd "C-c C-q") 'twittering-edit-cancel-status)
    (define-key twittering-edit-mode-map
      (kbd "C-u C-u") 'twittering-edit-replace-at-point)))

(unless (load "twittering-tinyurl-api-key" t t)
  (defvar twittering-bitly-api-key nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; pdf-preview settings
;;;

;; (autoload 'pdf-preview-buffer "pdf-preview" nil t)
;; (autoload 'pdf-preview-buffer-with-faces "pdf-preview" nil t)
;; (defvar ps-print-header nil)
;; (defvar pdf-preview-preview-command "open")
;; (defvar mew-print-function 'pdf-preview-buffer-with-faces)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; auto-async-byte-compile settings
;;;

;; (el-get-bundle auto-async-byte-compile)
;; (setq auto-async-byte-compile-exclude-files-regexp "/mac/") ;dummy
;; (setq auto-async-byte-compile-suppress-warnings t)
;; (add-hook 'emacs-lisp-mode-hook 'enable-auto-async-byte-compile-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; helm settings
;;;
(defvar helm-compile-source-functions nil 
   "Functions to compile elements of `helm-sources' (plug-in).")

(el-get-bundle helm
  (with-eval-after-load-feature 'helm
    (define-key helm-map (kbd "C-v") 'helm-next-source)
    (define-key helm-map (kbd "M-v") 'helm-previous-source)
    (defun helm-mac-spotlight ()
      "Preconfigured `helm' for `mdfind'."
      (interactive)
      (let ((helm-ff-transformer-show-only-basename nil))
	(helm-other-buffer 'helm-source-mac-spotlight "*helm mdfind*")))))

(defconst helm-for-files-preferred-list
  '(helm-source-buffers-list
    helm-source-recentf
    helm-source-file-cache
    helm-source-files-in-current-dir
    helm-source-mac-spotlight))
(setq helm-buffer-max-length 40
      helm-c-ack-thing-at-point 'symbol
      helm-ff-auto-update-initial-value nil
      helm-grep-default-recurse-command "ggrep -a -d recurse %e -n%cH -e %p %f"
      helm-input-idle-delay 0.2
      helm-mode t
      helm-truncate-lines t)

(el-get-bundle helm-migemo)
(el-get-bundle helm-ag
  (setq helm-ag-base-command "ag --nocolor --nogroup --ignore-case"
	helm-ag-command-option "--all-text"
	helm-ag-thing-at-point 'symbol))
(el-get-bundle helm-ack)
(el-get-bundle helm-gtags)
;; (el-get-bundle helm-cmd-t)
(el-get-bundle helm-ls-git)
(el-get-bundle helm-descbinds)

(defadvice helm-grep-highlight-match
    (around ad-helm-grep-highlight-match activate)
  (ad-set-arg 1 t)
  ad-do-it)

(setq helm-gtags-ignore-case t)
(setq helm-gtags-path-style 'relative)
;; grep for euc-jp.
;; (setq helm-grep-default-command "grep -a -d skip %e -n%cH -e `echo %p | lv -Ia -Oej` %f | lv -Os -Ia ")
;; (setq helm-grep-default-recurse-command "grep -a -d recurse %e -n%cH -e `echo %p | lv -Ia -Oej` %f | lv -Os -Ia ")

(el-get-bundle wgrep)
(setq wgrep-enable-key "r")

(add-hook 'helm-gtags-mode-hook
	  #'(lambda ()
	      (local-set-key (kbd "M-.") 'helm-gtags-find-tag)))

(global-set-key (kbd "C-;") 'helm-for-files)
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "C-z C-r") 'helm-resume)
(global-set-key (kbd "C-z C-f") 'helm-mac-spotlight)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(global-set-key (kbd "C-h b") 'helm-descbinds)
(global-set-key (kbd "C-z l") 'helm-ls-git-ls)


;;;
;;; see http://www49.atwiki.jp/ntemacs/pages/32.html
;;;

(defadvice helm-reduce-file-name (around ad-helm-reduce-file-name activate)
  (let ((fname (ad-get-arg 0))
        (level (ad-get-arg 1)))
    (while (> level 0)
      (setq fname (expand-file-name (concat fname "/../")))
      (setq level (1- level)))
    (setq ad-return-value fname)))

(defadvice helm-completing-read-default-1 (around ad-helm-completing-read-default-1 activate)
  (if (listp (ad-get-arg 4))
      (ad-set-arg 4 (car (ad-get-arg 4))))
  (cl-letf (((symbol-function 'regexp-quote)
          (symbol-function 'identity)))
    ad-do-it))

(defadvice find-file (around ad-find-file activate)
  (let ((current-prefix-arg nil))
    ad-do-it))

(require 'helm-howm)
(defvar hh:howm-data-directory howm-directory)
(setq hh:menu-list nil)
(setq hh:recent-menu-number-limit 100)

(defun helm-howm-do-grep ()
  (interactive)
  (helm-do-grep-1
   (list (car (split-string hh:howm-data-directory "\n"))) '(4) nil '("*.txt")))

(global-set-key (kbd "C-z ,") 'hh:menu-command)
(global-set-key (kbd "C-z .") 'hh:resume)
(global-set-key (kbd "C-z s") 'helm-howm-do-grep)

(with-eval-after-load "helm-migemo"
  (defun helm-compile-source--candidates-in-buffer (source)
    (helm-aif (assoc 'candidates-in-buffer source)
	(append source
		`((candidates
		   . ,(or (cdr it)
                          (lambda ()
                            ;; Do not use `source' because other plugins
                            ;; (such as helm-migemo) may change it
                            (helm-candidates-in-buffer (helm-get-current-source)))))
                  (volatile) (match identity)))
      source))
  (defalias 'helm-mp-3-get-patterns 'helm-mm-3-get-patterns)
  (defalias 'helm-mp-3-search-base 'helm-mm-3-search-base))

(el-get-bundle helm-c-yasnippet)
(setq helm-yas-space-match-any-greedy t)
(global-set-key (kbd "C-c y") 'helm-yas-complete)

(el-get-bundle helm-swoop)
(cl-defun helm-swoop-nomigemo (&key $query ($multiline current-prefix-arg))
  (interactive)
  (let (helm-migemo-mode)
    (helm-swoop :$query $query :$multiline $multiline)))

(defun isearch-forward-or-helm-swoop-or-helm-occur (use-helm-swoop)
  (interactive "p")
  (let (current-prefix-arg
        (helm-swoop-pre-input-function 'ignore))
    (call-interactively
     (case use-helm-swoop
       (1 'isearch-forward)		; C-s
       (4 (if (< 1000000 (buffer-size)) 'helm-occur 'helm-swoop)) ; C-u C-s
       (16 'helm-swoop-nomigemo)))))				  ; C-u C-u C-s
(global-set-key (kbd "C-s") 'isearch-forward-or-helm-swoop-or-helm-occur)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; yasnippet settings
;;;

(el-get-bundle yasnippet)
(yas-global-mode 1)
(defun yas/org-very-safe-expand ()
  (let ((yas/fallback-behavior 'return-nil)) (yas/expand)))
(add-hook 'org-mode-hook
          #'(lambda ()
	      ;; yasnippet (using the new org-cycle hooks)
	      (setq ac-use-overriding-local-map t)
	      (add-to-list 'org-tab-first-hook 'yas/org-very-safe-expand)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; popwin settings
;;;

(el-get-bundle! popwin
  (popwin-mode 1)
  (setq popwin:special-display-config
	(append
	 '(("*Async Shell Command*"		:noselect t)
	   ("^\*bzr-status.*\*"			:regexp t :noselect t)
	   ("^\*xgit-status.*\*"			:regexp t :noselect t)
	   ("*quickrun*"				:noselect t :tail t)
	   ("^\*karma.*\*"			:regexp t :noselect t :tail t))
	 popwin:special-display-config))

  (global-set-key (kbd "C-x C-p") popwin:keymap)
  (setq auto-async-byte-compile-display-function 'popwin:popup-buffer-tail))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; auto-save settings
;;;

(el-get-bundle! auto-save-buffers-enhanced in kentaro/auto-save-buffers-enhanced)
(setq auto-save-buffers-enhanced-interval 1.5)
(setq auto-save-buffers-enhanced-save-scratch-buffer-to-file-p t)
(setq auto-save-buffers-enhanced-file-related-with-scratch-buffer
      (concat howm-directory "scratch.txt"))
(auto-save-buffers-enhanced t)
(global-set-key "\C-xas" 'auto-save-buffers-enhanced-toggle-activity)

(el-get-bundle! scratch-pop in zk-phi/scratch-pop)
(global-set-key (kbd "C-c c") 'scratch-pop)
(makunbound 'scratch-ext-minor-mode-map)
(define-minor-mode scratch-ext-minor-mode
  "Minor mode for *scratch* buffer."
  nil ""
  '(("\C-c\C-c" . scratch-pop-kill-ring-save-exit)
    ("\C-c\C-e" . erase-buffer)))

(with-current-buffer (get-buffer-create "*scratch*")
  (erase-buffer)
  (ignore-errors
    (insert-file-contents auto-save-buffers-enhanced-file-related-with-scratch-buffer))
  (setq header-line-format "scratch!!")
  (scratch-ext-minor-mode 1))
(defun scratch-pop-kill-ring-save-exit ()
  "Save after close the contents of buffer to killring."
  (interactive)
  (kill-new (buffer-string))
  (erase-buffer)
  (funcall (if (fboundp 'popwin:close-popup-window)
               'popwin:close-popup-window
             'quit-window)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; UI async settings
;;;

(el-get-bundle! deferred)
(el-get-bundle! inertial-scroll in kiwanami/emacs-inertial-scroll
  (setq inertias-initial-velocity 50)
  (setq inertias-friction 120)
  (setq inertias-update-time 60)
  (setq inertias-rest-coef 0.1)
  (global-set-key (kbd "C-v") 'inertias-up)
  (global-set-key (kbd "M-v") 'inertias-down))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Emacs DBI settings
;;;
;;; cpan RPC::EPC::Service DBI DBD::SQLite DBD::Pg DBD::mysql
;;; e.g.) dbi:Pg:dbname=dbname;host=hostname;password=password
;;;

(el-get-bundle edbi
  (with-eval-after-load-feature 'edbi
    (setq edbi:query-result-fix-header nil
	  edbi:ds-history-list-num 50
	  edbi:query-result-column-max-width nil)))

;;; sqlite-dump
(el-get-bundle sqlite-dump)
(modify-coding-system-alist 'file "\\.\\(db\\|sqlite\\)\\'" 'raw-text-unix)
(add-to-list 'auto-mode-alist '("\\.\\(db\\|sqlite\\)\\'" . sqlite-dump))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; mkpasswd settings
;;;

(defvar mkpasswd-command
  "head -c 10 < /dev/random | uuencode -m - | tail -n 2 |head -n 1 | head -c10")
(autoload 'mkpasswd "mkpasswd" nil t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; id-manager settings
;;;

;; use gpg2 http://blog.n-z.jp/blog/2016-08-20-mac-easypg-gpg2.html
(setq idm-database-file (concat external-directory ".idm-db.gpg"))
(setq idm-copy-action 'kill-new)
(setq idm-gen-password-cmd mkpasswd-command)
(el-get-bundle id-manager in kiwanami/emacs-id-manager)
(setq epa-file-cache-passphrase-for-symmetric-encryption t)
(setenv "GPG_AGENT_INFO" nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; google-translate settings
;;;

(el-get-bundle google-translate)
(global-set-key "\C-ct" 'google-translate-at-point)
(global-set-key "\C-cT" 'google-translate-query-translate)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; locate settings
;;;

(defvar locate-home-database (expand-file-name "~/locate.database"))
(defvar locate-update-command
  (expand-file-name (concat user-bin-directory "locate.updatedb.sh")))
(defvar locate-update-command-program-args
  (list "nice" "-n" "19" locate-update-command))

(defvar helm-c-locate-command
  (concat "locate -i %s -d " locate-home-database " %s"))

(defun locate-update-home ()
  "offer to update the locate database in home."
  (interactive)
  (set-process-sentinel
   (apply 'start-process "locate-update-home" "*Messages*"
	  locate-update-command-program-args)
   #'(lambda (proc stat)
       (if (zerop (process-exit-status proc))
	   (message "locate.updatedb...done")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; nginx-mode settings
;;;
(el-get-bundle nginx-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; apachectl settings
;;;
;;;

(defvar apachectl-program-command "/usr/local/sbin/apachectl")
(defvar apachectl-buffer-name "*apachectl*")
(defun executable-apachectl (args)
"Executable apachectl command.
required setting with sudoers.

e.g.)
username ALL=NOPASSWD: /opt/local/apache2/bin/apachectl configtest,\\
         /opt/local/apache2/bin/apachectl start,\\
         /opt/local/apache2/bin/apachectl stop,\\
         /opt/local/apache2/bin/apachectl graceful,\\
         /opt/local/apache2/bin/apachectl restart
"
  (interactive)
  (let ((apachectl-command (list "sudo" apachectl-program-command args)))
    (with-current-buffer (get-buffer-create apachectl-buffer-name)
      (erase-buffer)
      (buffer-disable-undo)
      (set-process-sentinel
       (apply 'start-process (format "apachectl %s" args) (current-buffer)
	      apachectl-command)
       #'(lambda (proc stat)
	   (cond ((zerop (process-exit-status proc))
		  (message "%s... successful!" proc))
		 ((popwin:popup-buffer-tail apachectl-buffer-name)
		  (error "%s... failur!" proc))))))))
(defun apachectl/start ()
  (interactive)
  (executable-apachectl "start"))
(defun apachectl/stop ()
  (interactive)
  (executable-apachectl "stop"))
(defun apachectl/restart ()
  (interactive)
  (executable-apachectl "restart"))
(defun apachectl/configtest ()
  (interactive)
  (executable-apachectl "configtest"))
(defun apachectl/graceful ()
  (interactive)
  (executable-apachectl "graceful"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; convert to path settings
;;;

(defun convert-win-to-mac-path()
  (interactive)
  (let ((buf (get-buffer-create "*convert*")) str ret)
    (setq str (buffer-substring (region-beginning) (region-end)))
    (with-current-buffer
	buf (setq ret (buffer-string))
	(setq str (replace-regexp-in-string
		   "\\\\\\\\[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+" "/Volumes" str))
	(setq str (replace-regexp-in-string "\\\\" "/" str))
	(insert str))
    (kill-buffer buf)
    (message "%s" str)
    (kill-new str)
    (delete-region (region-beginning) (region-end))
    (insert str)))

(defun convert-smb-to-win-path()
  (interactive)
  (let ((buf (get-buffer-create "*convert*")) str ret)
    (setq str (buffer-substring (region-beginning) (region-end)))
    (with-current-buffer
	buf (setq ret (buffer-string))
	(setq str (ucs-normalize-NFC-string str))
	(setq str (replace-regexp-in-string "smb://" "\\\\\\\\" str))
	(setq str (replace-regexp-in-string "/" "\\\\" str))
	(insert str))
    (kill-buffer buf)
    (message "%s" str)
    (kill-new str)
    (delete-region (region-beginning) (region-end))
    (insert str)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; po-mode.el settings
;;;

(el-get-bundle po-mode)
(setq auto-mode-alist (cons '("\\.po\\'\\|\\.po\\." . po-mode)
			    auto-mode-alist))

(autoload 'po-find-file-coding-system "po-compat")
(modify-coding-system-alist 'file "\\.po\\'\\|\\.po\\."
			    'po-find-file-coding-system)

(define-key minibuffer-local-map (kbd "C-j") 'skk-kakutei)
(setq gc-cons-threshold 800000)
(put 'downcase-region 'disabled nil)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
)

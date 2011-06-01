;;; izonmoji-mode.el --- Visualize Windows and Macintosh izonmoji

;; Copyright (C) 2002-2004 by Navi2ch Project

;; Author: SAITO Takuya <tabmore@users.sourceforge.net>
;; Keywords: 2ch, charset

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;; izonmoji-mode() and the way to apply izonmoji-{win,mac}-face on GNU Emacs
;; are derived from

;; blank-mode.el
;; Author: Vinicius Jose Latorre <vinicius@cpqd.com.br>
;; Version: 4.0
;; X-URL: http://www.cpqd.com.br/~vinicius/emacs/

;;; Commentary:

;; 機種依存文字を表示可能な文字列に置き換えて表示する。
;; デフォルトでは置換先に JISX0213 の文字も使っていますので、
;; JISX0213用のフォントが必要です。
;; 全ての機種依存文字を表示できるわけではありませんので注意。

;; commands:
;;   izonmoji-mode      機種依存文字表示をトグル
;;   izonmoji-mode-on   機種依存文字を表示
;;   izonmoji-mode-off  機種依存文字表示をやめる

;; coding-system:
;;   izonmoji-shift-jis 読み込み時に、IBM拡張文字を対応するNEC特殊文字、
;;                      NEC選定IBM拡張文字に置換する。

;; izonmoji-mode-on は buffer の内容を変更しませんが、izonmoji-shift-jis で
;; ファイルを読み込んだ時と shift_jisで読み込んだ時とでは buffer の内容が
;; 異なる場合もありますので、意図せずに file の内容を変更しないよう注意
;; して下さい。

;; Emacs のバージョン
;;  Emacs 20 以降、XEmacs 21.4 以降を使って下さい。
;;  ただし、XEmacs 21.1 でも一部の機能は使えます。

;; GNU Emacs 20 では、Mule-UCSが必要です。
;; このファイルを読み込む前に (require 'jisx0213) してください。

;; GNU Emacs 20,21では、buffer-display-tableによって表示を置き替えた
;; Non-ASCIIな文字のchar-widthがおかしくなります。
;; 変換前後でchar-widthが変わらない場合は、
;;  (defadvice char-width (around display-table-hack activate)
;;    (let ((buffer-display-table nil))
;;      ad-do-it))
;; でごまかせます。 string-widthも同様です。

;; XEmacs 21.4以前ではinit-fileに以下のように書いてください。
;; (make-charset
;;  'japanese-jisx0213-1
;;  "JIS X 0213:2000 Plain 1"
;;  '(registry "jisx0213\\(\\.2000\\)-1"
;;             dimension 2 chars 94 final ?O graphic 0))
;; (make-charset
;;  'japanese-jisx0213-2
;;  "JIS X 0213:2000 Plain 2"
;;  '(registry "jisx0213\\(\\.2000\\)-2"
;;             dimension 2 chars 94 final ?P graphic 0))

;; 設定例

;; [共通] ~/.emacs へ
;;  (require 'izonmoji-mode)

;; [navi2ch] ~/.navi2ch/init.el へ
;;  (add-hook 'navi2ch-bm-mode-hook      'izonmoji-mode-on)
;;  (add-hook 'navi2ch-article-mode-hook 'izonmoji-mode-on)
;;  (add-hook 'navi2ch-popup-article-mode-hook 'izonmoji-mode-on)
;;  ;; IBM拡張文字を表示 (XEmacs-21.1 は非対応)
;;  (when (memq 'izonmoji-shift-jis (coding-system-list))
;;    (setq navi2ch-coding-system 'izonmoji-shift-jis))

;; [Mew] ~/.mew.el へ
;;  (add-hook 'mew-message-mode-hook 'izonmoji-mode-on)

;; [Wanderlust] ~/.wl へ
;;  (add-hook 'wl-message-redisplay-hook 'izonmoji-mode-on)

;; [emacs-w3m] ~/.emacs-w3m.el へ
;;  (add-hook 'w3m-mode-hook 'izonmoji-mode-on)

;;; Bugs:

;;  1. display-tableをいじる
;;  2. M-x izonmoji-mode-on
;;  3. 1の変更を元に戻す
;;  4. M-x izonmoji-mode-off
;;  すると元にもどらない。
;;  C-u M-x izonmoji-mode-off してdisplay-tableへの全ての変更を取り消す
;;  ことはできます。


;;; Code:

(eval-when-compile
  (defvar buffer-display-table)
  (defvar current-display-table))

(require 'ccl)

(defvar izonmoji-priority-list '(win mac)
  "*表示の優先順位。
'(win mac) なら、Windowsの機種依存文字を優先しつつ、Macの文字も表示。
'(win) なら、Windowsの機種依存文字のみ表示。")

(defvar izonmoji-win-face 'izonmoji-win-face
  "*Windowsの機種依存文字の表示に使うフェイス名。
'default にするとフェイスをつけません。")

(defvar izonmoji-mac-face 'izonmoji-mac-face
  "*Macの機種依存文字の表示に使うフェイス名。
'default にするとフェイスをつけません。")

(defface izonmoji-win-face
  '((((class color) (type tty)) (:foreground "cyan"))
    (((class color) (background light)) (:foreground "Aquamarine4"))
    (((class color) (background dark))  (:foreground "Aquamarine3"))
    (t (:underline t)))
  "Windowsの機種依存文字のフェイス。")

(defface izonmoji-mac-face
  '((((class color) (type tty)) (:foreground "magenta"))
    (((class color) (background light)) (:foreground "pink4"))
    (((class color) (background dark))  (:foreground "pink3"))
    (t (:underline t)))
  "Macの機種依存文字のフェイス。")

(defvar izonmoji-win-display-list
  '("①" "②" "③" "④" "⑤" "⑥" "⑦" "⑧" "⑨" "⑩"
    "⑪" "⑫" "⑬" "⑭" "⑮" "⑯" "⑰" "⑱" "⑲" "⑳"
    "Ⅰ" "Ⅱ" "Ⅲ" "Ⅳ" "Ⅴ" "Ⅵ" "Ⅶ" "Ⅷ" "Ⅸ" "Ⅹ"
    "㍉" "㌔" "㌢" "㍍" "㌘" "㌧" "㌃" "㌶" "㍑" "㍗" "㌍" "㌦"
    "㌣" "㌫" "㍊" "㌻" "㎜" "㎝" "㎞" "㎎" "㎏" "㏄" "㎡"
    "㍻" "〝" "〟" "№" "㏍" "℡" "㊤" "㊥" "㊦" "㊧" "㊨"
    "㈱" "㈲" "㈹" "㍾" "㍽" "㍼"
    "≒" "≡" "∫" "∮" "Σ" "√" "⊥" "∠" "∟" "⊿" "∵" "∩" "∪"
    "纊" "褜" "鍈" "銈" "蓜" "俉" "炻" "昱" "棈" "鋹" "曻" "彅" "丨" "仡"
    "仼" "伀" "伃" "伹" "佖" "侒" "侊" "侚" "侔" "俍" "偀" "倢" "俿" "倞"
    "偆" "偰" "偂" "傔" "僴" "僘" "兊" "兤" "冝" "冾" "凬" "刕" "劜" "劦"
    "勀" "勛" "匀" "匇" "匤" "卲" "厓" "厲" "叝" "〓" "咜" "咊" "咩" "哿"
    "喆" "坙" "坥" "垬" "埈" "埇" "﨏" "塚" "增" "墲" "夋" "奓" "奛" "奝"
    "奣" "妤" "妺" "孖" "寀" "甯" "寘" "寬" "尞" "岦" "岺" "峵" "崧" "嵓"
    "﨑" "嵂" "嵭" "嶸" "嶹" "巐" "弡" "弴" "彧" "德" "忞" "恝" "悅" "悊"
    "惞" "惕" "愠" "惲" "愑" "愷" "愰" "憘" "戓" "抦" "揵" "摠" "撝" "擎"
    "敎" "昀" "昕" "昻" "昉" "昮" "昞" "昤" "晥" "晗" "晙" "〓" "晳" "暙"
    "暠" "暲" "暿" "曺" "朎" "朗" "杦" "枻" "桒" "柀" "栁" "桄" "棏" "﨓"
    "楨" "﨔" "榘" "槢" "樰" "橫" "橆" "橳" "橾" "櫢" "櫤" "毖" "氿" "汜"
    "沆" "汯" "泚" "洄" "涇" "浯" "涖" "涬" "淏" "淸" "淲" "淼" "渹" "湜"
    "渧" "渼" "溿" "澈" "澵" "濵" "瀅" "瀇" "瀨" "炅" "炫" "焏" "焄" "煜"
    "煆" "煇" "凞" "燁" "燾" "犱" "犾" "猤" "猪" "獷" "玽" "珉" "珖" "珣"
    "珒" "琇" "珵" "琦" "琪" "琩" "琮" "瑢" "璉" "璟" "甁" "畯" "皂" "皜"
    "皞" "皛" "皦" "〓" "睆" "劯" "砡" "硎" "硤" "硺" "礰" "〓" "神" "祥"
    "禔" "福" "禛" "竑" "竧" "〓" "竫" "箞" "〓" "絈" "絜" "綷" "綠" "緖"
    "繒" "罇" "羡" "〓" "茁" "荢" "荿" "菇" "菶" "葈" "蒴" "蕓" "蕙" "蕫"
    "﨟" "薰" "蘒" "﨡" "蠇" "裵" "訒" "訷" "詹" "誧" "誾" "諟" "諸" "諶"
    "譓" "譿" "賰" "賴" "贒" "赶" "〓" "軏" "﨤" "〓" "遧" "郞" "都" "鄕"
    "鄧" "釚" "釗" "釞" "釭" "釮" "釤" "釥" "鈆" "鈐" "鈊" "鈺" "鉀" "鈼"
    "鉎" "鉙" "鉑" "鈹" "鉧" "銧" "鉷" "鉸" "鋧" "鋗" "鋙" "鋐" "〓" "鋕"
    "鋠" "鋓" "錥" "錡" "鋻" "〓" "錞" "鋿" "錝" "錂" "鍰" "鍗" "鎤" "鏆"
    "鏞" "鏸" "鐱" "鑅" "鑈" "閒" "隆" "〓" "隝" "隯" "霳" "霻" "靃" "靍"
    "靏" "靑" "靕" "顗" "顥" "〓" "〓" "餧" "〓" "馞" "驎" "髙" "髜" "魵"
    "魲" "鮏" "鮱" "鮻" "鰀" "鵰" "鵫" "〓" "鸙" "黑"
    "ⅰ" "ⅱ" "ⅲ" "ⅳ" "ⅴ" "ⅵ" "ⅶ" "ⅷ" "ⅸ" "ⅹ" "¬" "¦" "＇" "＂")
  "*Windowsの機種依存文字の表示に使う文字列のリスト。")

(defvar izonmoji-mac-display-list
  '("①" "②" "③" "④" "⑤" "⑥" "⑦" "⑧" "⑨" "⑩"
    "⑪" "⑫" "⑬" "⑭" "⑮" "⑯" "⑰" "⑱" "⑲" "⑳"
    "(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)" "(10)"
    "(11)" "(12)" "(13)" "(14)" "(15)" "(16)" "(17)" "(18)" "(19)" "(20)"
    "❶" "❷" "❸" "❹" "❺" "❻" "❼" "❽" "❾"
    "0." "1." "2." "3." "4." "5." "6." "7." "8." "9." "0." ;0. はどこ？
    "Ⅰ" "Ⅱ" "Ⅲ" "Ⅳ" "Ⅴ" "Ⅵ" "Ⅶ" "Ⅷ" "Ⅸ" "Ⅹ"
    "Ⅺ" "Ⅻ" "XⅢ" "XⅣ" "XV"
    "ⅰ" "ⅱ" "ⅲ" "ⅳ" "ⅴ" "ⅵ" "ⅶ" "ⅷ" "ⅸ" "ⅹ"
    "ⅺ" "ⅻ" "xⅲ" "xⅳ" "xv"
    "(a)" "(b)" "(c)" "(d)" "(e)" "(f)" "(g)" "(h)" "(i)" "(j)" "(k)"
    "(l)" "(m)" "(n)" "(o)" "(p)" "(q)" "(r)" "(s)" "(t)" "(u)" "(v)"
    "(w)" "(x)" "(y)" "(z)"
    "㎜" "mm²" "㎝" "㎝²" "㎝³" "m" "㎡" "m³" "㎞" "k㎡"
    "㎎" "g" "㎏" "㏄" "mℓ" "dℓ" "ℓ" "kℓ"
    "ms" "μs" "ns" "ps" "°F" "mb" "㏋" "Hz" "KB" "MB" "GB" "TB"
    "№" "㏍" "℡" "FAX"
    "♤" "♧" "♡" "♢" "♠" "♣" "♥" "♦"
    "〠" "☎" "JIS"			;JISマーク
    "→" "←" "↑" "↓"			;指差し矢印
    "⇄" "⇄" "↑↓" "↓↑"	     ;偶数番目は、上下、左右の向きが逆
    "⇨" "⇦" "⇧" "⇩" "⇨" "⇦" "⇧" "⇩" ;後半は塗り潰し
    "(日)" "(月)" "(火)" "(水)" "(木)" "(金)" "(土)"
    "(祭)" "(祝)" "(自)" "(至)" "㈹" "(呼)" "㈱" "(資)" "(名)"
    "㈲" "(学)" "(財)" "(社)" "(特)" "(監)" "(企)" "(協)" "(労)"
    "(大)" "(小)" "㊤" "㊥" "㊦" "㊧" "㊨"
    "(医)" "(財)" "(優)" "(労)" "(印)" "(控)" "(秘)" ;本当は丸付き
    "㍉" "㌢" "㍍" "㌔" "㌔㍍" "ｲﾝﾁ" "ﾌｨｰﾄ" "ﾔｰﾄﾞ" "㌃" "㌶"
    "㌘" "㌔㌘" "㌧" "㍑" "㍊" "ﾍﾙﾂ" "㍗" "㌍" "ﾎｰﾝ" "㌣" "㌦" "㌻" "㌫"
    "ｱﾊﾟｰﾄ" "ｺｰﾎﾟ" "ﾊｲﾂ" "ﾋﾞﾙ" "ﾏﾝｼｮﾝ"
    "㍾" "㍽" "㍼" "㍻"
    "株式会社" "有限会社" "財団法人"	;"㈱" "㈲"
    "∮" "∟" "⊿"
    "〝" "〟"
    "ゔ" "ヷ" "ヸ" "ヹ" "ヺ"
    ;; 縦書き
    "、" "。" "￣" "＿" "ー" "─" "‐" "〜"
    "＝" "─"				;横直線
    "…" "‥" "（" "）" "〔" "〕" "［" "］" "｛" "｝" "〈" "〉" "《" "》"
    "「" "」" "『" "』" "【" "】" "＝"
    "ぁ" "ぃ" "ぅ" "ぇ" "ぉ" "っ" "ゃ" "ゅ" "ょ" "ゎ"
    "ァ" "ィ" "ゥ" "ェ" "ォ" "ッ" "ャ" "ュ" "ョ" "ヮ" "ヵ" "ヶ")
  "*Macの機種依存文字の表示に使う文字列のリスト。")

(defun izonmoji-make-char-list (i js je &optional k)
  (unless k (setq k 1))
  (let ((j js) list)
    (while (<= j je)
      (setq list (cons (make-char 'japanese-jisx0208 i j) list))
      (setq j (+ j k)))
    (nreverse list)))

;; Windowsの丸付き1は、
;; (split-char (decode-sjis-char (hexl-hex-string-to-integer "8740")))
(defvar izonmoji-win-chars-list
  (append
   (izonmoji-make-char-list  45  33  62) ;丸付き数字 + ローマ数字(大文字)
   (izonmoji-make-char-list  45  64  86) ;単位
   (izonmoji-make-char-list  45  95 124) ;元号、数学記号など
   (izonmoji-make-char-list 121  33 126) ;漢字
   (izonmoji-make-char-list 122  33 126)
   (izonmoji-make-char-list 123  33 126)
   (izonmoji-make-char-list 124  33 110)
   (izonmoji-make-char-list 124 113 126) ;ローマ数字(小文字)
   )
  "*Windowsの機種依存文字リスト。")

(defvar izonmoji-mac-chars-list
  (append
   (izonmoji-make-char-list  41  33  52) ;丸付き数字
   (izonmoji-make-char-list  41  63  82) ;括弧付き数字
   (izonmoji-make-char-list  41  93 101) ;黒丸付き数字
   (izonmoji-make-char-list  41 113 123) ;点付き数字
   (izonmoji-make-char-list  42  33  47) ;ローマ数字(大文字)
   (izonmoji-make-char-list  42  53  67) ;ローマ数字(小文字)
   (izonmoji-make-char-list  42  93 118) ;括弧付きアルファベット
   (izonmoji-make-char-list  43  33  62) ;単位
   (izonmoji-make-char-list  43 123 126) ;略号
   (izonmoji-make-char-list  44  33  40) ;トランプ
   (izonmoji-make-char-list  44  53  55) ;郵便
   (izonmoji-make-char-list  44  73  88) ;矢印
   (izonmoji-make-char-list  45  33  57) ;曜日など
   (izonmoji-make-char-list  45 113 126) ;丸付き文字
   (izonmoji-make-char-list  46  33  55) ;カタカナ単位
   (izonmoji-make-char-list  46  63  67) ;アパート
   (izonmoji-make-char-list  46 103 106) ;元号
   (izonmoji-make-char-list  46 124 126) ;株式会社
   (izonmoji-make-char-list  47  33  35) ;数学記号
   (izonmoji-make-char-list  47  53  54) ;""
   (izonmoji-make-char-list  47  73  73) ;う゛
   (izonmoji-make-char-list  47  75  78) ;ワ゛
   (izonmoji-make-char-list 117  34  35) ;縦書き
   (izonmoji-make-char-list 117  49  50)
   (izonmoji-make-char-list 117  60  62)
   (izonmoji-make-char-list 117  65  69)
   (izonmoji-make-char-list 117  74  91)
   (izonmoji-make-char-list 117  97  97)
   (izonmoji-make-char-list 120  33  41 2)
   (izonmoji-make-char-list 120  67  67)
   (izonmoji-make-char-list 120  99  99)
   (izonmoji-make-char-list 120 101 103 2)
   (izonmoji-make-char-list 120 110 110)
   (izonmoji-make-char-list 121  33  41 2)
   (izonmoji-make-char-list 121  67  67)
   (izonmoji-make-char-list 121  99  99)
   (izonmoji-make-char-list 121 101 103 2)
   (izonmoji-make-char-list 121 110 110)
   (izonmoji-make-char-list 121 117 118))
  "*Macの機種依存文字リスト。")

(defvar izonmoji-mode-hook nil "*機種依存文字を表示した後に呼ばれるフック。")

;; Internal variables

(defvar izonmoji-mode nil)
(make-variable-buffer-local 'izonmoji-mode)

(defvar izonmoji-backuped-display-table nil)
(make-variable-buffer-local 'izonmoji-backuped-display-table)

(defun izonmoji-mode (&optional arg)
  "機種依存文字表示をトグル。
ARG が non-nil の場合、1以上の数なら機種依存文字を表示。
それ以外なら機種依存文字表示をやめる。"
  (interactive "P")
  (if (if arg
	  (> (prefix-numeric-value arg) 0)
	(not izonmoji-mode))
      (izonmoji-mode-on)
    (izonmoji-mode-off)))

(defun izonmoji-mode-on (&optional reverse win-face mac-face)
  "機種依存文字を表示"
  (interactive "P")
  (let ((priority (reverse izonmoji-priority-list))
	from to table)
    (when reverse
      (setq priority (nreverse priority)))
    (unless izonmoji-mode
      (cond
       ((featurep 'xemacs)
	(let* ((ctable (specifier-instance current-display-table))
	       (len (- (1+ (apply 'max (append izonmoji-win-chars-list
					       izonmoji-mac-chars-list)))
		       (length ctable)))
	       face glyph)
	  (setq izonmoji-backuped-display-table ctable
		table (copy-sequence ctable))
	  (when (> len 0)
	    (setq table (vconcat table (make-vector len nil))))
	  (while priority
	    (cond
	     ((eq (car priority) 'win)
	      (setq from izonmoji-win-chars-list
		    to   izonmoji-win-display-list
		    face (or win-face izonmoji-win-face 'default)))
	     ((eq (car priority) 'mac)
	      (setq from izonmoji-mac-chars-list
		    to   izonmoji-mac-display-list
		    face (or mac-face izonmoji-mac-face 'default))))
	    (setq priority (cdr priority))
	    (while (and from to)
	      (if (or (eq face 'default)
		      ;; XEmacs 21.1 で face を付けると落ちるので。
		      (and (= emacs-major-version 21)
			   (= emacs-minor-version 1)))
		  ;; face を指定しない。
		  (aset table (car from) (car to))
		(setq glyph (make-glyph (car to)))
		(set-glyph-face glyph face)
		(aset table (car from) glyph))
	      (setq from (cdr from) to (cdr to))))
	  (set-specifier current-display-table table (current-buffer))))
       (t				;GNU Emacs
	(let (face-bits)
	  (setq izonmoji-backuped-display-table buffer-display-table
		table (or (copy-sequence (or buffer-display-table
					     standard-display-table))
			  (make-display-table)))
	  (while priority
	    (cond
	     ((eq (car priority) 'win)
	      (setq from izonmoji-win-chars-list
		    to   izonmoji-win-display-list
		    face-bits (ash (face-id
				    (or win-face izonmoji-win-face 'default))
				   19)))
	     ((eq (car priority) 'mac)
	      (setq from izonmoji-mac-chars-list
		    to   izonmoji-mac-display-list
		    face-bits (ash (face-id
				    (or mac-face izonmoji-mac-face 'default))
				   19))))
	    (setq priority (cdr priority))
	    (while (and from to)
	      (aset table (car from)
		    (apply 'vector (mapcar
				    (lambda (ch) (logior ch face-bits))
				    (car to))))
	      (setq from (cdr from) to (cdr to))))
	  (setq buffer-display-table table)))))
    (setq izonmoji-mode t)
    (run-hooks 'izonmoji-mode-hook)))

(defun izonmoji-mode-off (&optional initialize)
  "機種依存文字表示をやめる"
  (interactive "P")
  (when initialize
    (setq izonmoji-mode t
	  izonmoji-backuped-display-table (make-display-table)))
  (when izonmoji-mode
    (if (featurep 'xemacs)
	(set-specifier current-display-table
		       izonmoji-backuped-display-table (current-buffer))
      (setq buffer-display-table izonmoji-backuped-display-table))
    (setq izonmoji-mode nil)))

;; izonmoji-shift-jis
(when (and (fboundp 'ccl-compile-write-multibyte-character)
	   (not (memq 'izonmoji-shift-jis (coding-system-list))))
  (eval-and-compile
    (defun izonmoji-ccl-write-sjis ()
      `((r1 = (r0 de-sjis r1))
	(r0 = (r1 << 7))
	(r0 += r7)
	(r1 = ,(charset-id 'japanese-jisx0208))
	(write-multibyte-character r1 r0)
	(repeat)))

    (defun izonmoji-ccl-ibm-ext (d0 d1)
      `((r0 -= ,d0)
	(r1 -= ,d1)
	,@(izonmoji-ccl-write-sjis))))

  (define-ccl-program izonmoji-shift-jis-decode
    `(2
      (loop
       (read r0)
       (if (r0 < ?\x80)
	   (write-repeat r0))
       ;; if (r0 == 0x80 || r0 == 0xA0 || 0xEF < r0 < 0xFA || r0 > 0xFC)
       (r1 = (r0 == ?\x80))
       (r1 |= (r0 == ?\xA0))
       (r2 = (r0 > ?\xEF))
       (r2 &= (r0 < ?\xFA))
       (r1 |= r2)
       (r1 |= (r0 > ?\xFC))
       (if r1
	   (write-repeat r0))
       (r1 = (r0 <= ?\x9F))
       (r1 |= (r0 >= ?\xE0))
       (if r1
	   ((read r1)
	    (r2 = (r1 < ?\x40))
	    (r2 |= (r1 == ?\x7F))
	    (r2 |= (r1 > ?\xFC))
	    (if r2
		((write r0)
		 (write-repeat r1)))
	    (if (r0 >= ?\xFA)
		((if (r0 == ?\xFA)
		     ((if (r1 <= ?\x49)
			  ,(izonmoji-ccl-ibm-ext 12 -175))
		      (if (r1 <= ?\x53)
			  ,(izonmoji-ccl-ibm-ext 115 -10))
		      (if (r1 <= ?\x57)
			  ,(izonmoji-ccl-ibm-ext 12 -165))
		      (if (r1 == ?\x58)
			  ,(izonmoji-ccl-ibm-ext 115 -50))
		      (if (r1 == ?\x59)
			  ,(izonmoji-ccl-ibm-ext 115 -41))
		      (if (r1 == ?\x5A)
			  ,(izonmoji-ccl-ibm-ext 115 -42))
		      (if (r1 == ?\x5B)
			  ,(izonmoji-ccl-ibm-ext 115 -63))
		      (if (r1 <= ?\x7E)
			  ,(izonmoji-ccl-ibm-ext 13 28))
		      (if (r1 <= ?\x9B)
			  ,(izonmoji-ccl-ibm-ext 13 29))
		      (if (r1 <= ?\xFC)
			  ,(izonmoji-ccl-ibm-ext 13 28))))
		 (if (r0 == ?\xFB)
		     ((if (r1 <= ?\x5B)
			  ,(izonmoji-ccl-ibm-ext 14 -161))
		      (if (r1 <= ?\x7E)
			  ,(izonmoji-ccl-ibm-ext 13 28))
		      (if (r1 <= ?\x9B)
			  ,(izonmoji-ccl-ibm-ext 13 29))
		      (if (r1 <= ?\xFC)
			  ,(izonmoji-ccl-ibm-ext 13 28))))
		 (if (r0 == ?\xFC)
		     ((if (r1 <= ?\x4B)
			  ,(izonmoji-ccl-ibm-ext 14 -161))))
		 (write r0)
		 (write-repeat r1)))
	    ,@(izonmoji-ccl-write-sjis))
	 ((r0 &= ?\x7F)
	  (r1 = ,(charset-id 'katakana-jisx0201))
	  (write-multibyte-character r1 r0)
	  (repeat))))))

  (define-ccl-program izonmoji-shift-jis-encode
    `(1
      (loop
       (read r0)
       (if (r0 == ,(charset-id 'japanese-jisx0208))
	   ((read r0)
	    (read r1)
	    (r0 &= ?\x7F)
	    (r1 &= ?\x7F)
	    (r1 = (r0 en-sjis r1))
	    (write r1 r7)
	    (repeat))
	 ((if (r0 == ,(charset-id 'katakana-jisx0201))
	      (read r0))
	  (write-repeat r0))))))

  (if (featurep 'xemacs)
      (make-coding-system 'izonmoji-shift-jis 'ccl
			  "Shift-JIS for displaying IBM ext characters"
			  (list 'mnemonic "S"
				'decode 'izonmoji-shift-jis-decode
				'encode 'izonmoji-shift-jis-encode))
    (make-coding-system 'izonmoji-shift-jis 4 ?S
			"Shift-JIS for displaying IBM ext characters"
			(cons 'izonmoji-shift-jis-decode
			      'izonmoji-shift-jis-encode)
			(list (cons 'safe-charsets
				    (coding-system-get 'japanese-shift-jis
						       'safe-charsets))))))

(add-to-list 'minor-mode-alist '(izonmoji-mode " Iz"))

(provide 'izonmoji-mode)

;;; izonmoji-mode.el ends here

extends Control

# このBokiNodeが担当する勘定科目データ
var account_data: Account

# --- Node References ---
# スクリプトから操作したい子ノードへの参照をあらかじめ取得しておきます。
@onready var background: ColorRect = $Background
@onready var account_name_label: Label = $MarginContainer/VBoxContainer/AccountNameLabel
@onready var balance_label: Label = $MarginContainer/VBoxContainer/BalanceLabel


# --- Public Methods ---

# このBokiNodeの初期設定を行う関数。
# Controller (Main.gd) が、どの勘定科目を表示するかを指示するために呼び出します。
func setup(data: Account):
	self.account_data = data
	
	# 受け取ったデータを使って、見た目を更新する
	account_name_label.text = account_data.name
	update_balance()


# 残高表示を更新する関数
func update_balance():
	# 数字を3桁区切りの通貨形式（例: ¥1,000,000）にフォーマットして表示します。
	# Godot 4では、数値をフォーマットする際は配列 `[]` で渡すのが標準的です。
	if account_data:
		print("  - [BokiNode] Updating balance for '", account_data.name, "' to: ", account_data.balance)
		# format関数が期待通りに動作しない環境を考慮し、より確実な文字列結合に切り替える
		balance_label.text = "¥" + str(account_data.balance)

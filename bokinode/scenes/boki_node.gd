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
	account_name_label.text = account_data.display_name
	update_balance()


# 残高表示を更新する関数
func update_balance():
	# 数字を3桁区切りの通貨形式（例: ¥1,000,000）にフォーマットして表示します。
	# これにより、大きな数字でも格段に見やすくなります。
	balance_label.text = "¥{:,}".format({"_": int(account_data.balance)})

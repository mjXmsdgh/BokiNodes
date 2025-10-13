extends Node

# 再利用するBokiNodeシーンをあらかじめ読み込んでおく
const BokiNodeScene = preload("res://scenes/BokiNode.tscn")

# --- Node References ---
@onready var boki_node_container = $World/BokiNodeContainer
@onready var title_label = $UI/TutorialPanel/MarginContainer/VBoxContainer/TitleLabel
@onready var description_label = $UI/TutorialPanel/MarginContainer/VBoxContainer/DescriptionLabel
@onready var next_button = $UI/NextButton

# --- Member Variables ---
# 生成したBokiNodeのインスタンスを、勘定科目IDをキーにして保持する辞書
var boki_nodes: Dictionary = {}

# 現在のチュートリアルの取引データ
var current_transaction: Transaction


func _ready():
	# 1. BokiNodeを画面上に生成・配置する
	_setup_nodes()
	# 2. ボタンやLedgerからのシグナルを接続する
	_connect_signals()
	# 3. 最初の取引情報を表示して、ユーザーの操作を待つ
	_prepare_next_step()


# Ledgerに登録されている勘定科目の数だけ、BokiNodeを生成・配置する
func _setup_nodes():
	var all_accounts = Ledger.accounts.values()
	for i in range(all_accounts.size()):
		var account_data = all_accounts[i]
		var node_instance = BokiNodeScene.instantiate()
		
		# TODO: ここで各ノードを適切な位置に配置するロジックを追加
		node_instance.position = Vector2(100 + (i % 3) * 250, 150 + (i / 3) * 150)
		
		boki_node_container.add_child(node_instance)
		boki_nodes[account_data.id] = node_instance

		# シーンツリーに追加した後で初期設定を呼び出す
		node_instance.setup(account_data)


# 各種シグナルを対応する関数に接続する
func _connect_signals():
	next_button.pressed.connect(_on_next_button_pressed)
	Ledger.account_updated.connect(_on_account_updated)


# 次の取引の準備をする
func _prepare_next_step():
	current_transaction = Ledger.get_next_transaction()
	if current_transaction:
		description_label.text = current_transaction.description
		next_button.disabled = false
	else:
		description_label.text = "チュートリアル完了！"
		next_button.disabled = true


# 「次の取引へ」ボタンが押されたときに呼ばれる
func _on_next_button_pressed():
	Ledger.execute_transaction(current_transaction)
	_prepare_next_step()


# Ledger側で勘定科目の残高が更新されたときに呼ばれる
func _on_account_updated(updated_account: Account):
	var node_to_update = boki_nodes.get(updated_account.id)
	if node_to_update:
		node_to_update.update_balance()

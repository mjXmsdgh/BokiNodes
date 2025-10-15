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
	print("--- [Main] _ready: 処理開始 ---")
	# 1. BokiNodeを画面上に生成・配置する
	_setup_nodes()
	# 2. ボタンやLedgerからのシグナルを接続する
	_connect_signals()
	# 3. 最初の取引情報を表示して、ユーザーの操作を待つ
	_prepare_next_step()


# Ledgerに登録されている勘定科目の数だけ、BokiNodeを生成・配置する
func _setup_nodes():
	print("--- [Main] _setup_nodes: ノードのセットアップを開始 ---")
	
	# 勘定科目の種類ごとにノードを整理するための辞書
	var categorized_nodes: Dictionary = {
		Account.Type.ASSET: [],
		Account.Type.LIABILITY: [],
		Account.Type.EQUITY: [],
		Account.Type.REVENUE: [],
		Account.Type.EXPENSE: [],
	}

	# Ledger.accounts辞書の値（Accountリソース）を一つずつ取り出す
	for account_data in Ledger.accounts.values():
		var node_instance = BokiNodeScene.instantiate()
		boki_node_container.add_child(node_instance)
		# Accountリソースが持つ `id` をキーとして、ノードのインスタンスを辞書に登録
		boki_nodes[account_data.id] = node_instance
		print("  - Setting up node for: '", account_data.name, "' with ID: '", account_data.id, "'")
		node_instance.setup(account_data)

		categorized_nodes[account_data.account_type].append(node_instance)

	# 簿記のレイアウトに合わせて配置（左側に資産、右側にその他）
	_layout_nodes(categorized_nodes[Account.Type.ASSET], Vector2(150, 200))
	_layout_nodes(categorized_nodes[Account.Type.LIABILITY], Vector2(500, 150))
	_layout_nodes(categorized_nodes[Account.Type.EQUITY], Vector2(500, 300))
	_layout_nodes(categorized_nodes[Account.Type.REVENUE], Vector2(850, 150))
	_layout_nodes(categorized_nodes[Account.Type.EXPENSE], Vector2(850, 300))
	print("--- [Main] _setup_nodes: ノードのセットアップ完了 ---")

func _layout_nodes(nodes: Array, start_pos: Vector2):
	for i in range(nodes.size()):
		nodes[i].position = start_pos + Vector2(0, i * 120)

# 各種シグナルを対応する関数に接続する
func _connect_signals():
	print("--- [Main] _connect_signals: シグナル接続を開始 ---")
	next_button.pressed.connect(_on_next_button_pressed)
	Ledger.account_updated.connect(_on_account_updated)
	print("--- [Main] _connect_signals: シグナル接続完了 ---")


# 次の取引の準備をする
func _prepare_next_step():
	print("--- [Main] _prepare_next_step: 次の取引を準備 ---")
	current_transaction = Ledger.get_next_transaction()
	if current_transaction:
		print("  - 次の取引: ", current_transaction.description)
		description_label.text = current_transaction.description
		next_button.disabled = false
	else:
		print("  - 全ての取引が完了しました。")
		description_label.text = "チュートリアル完了！"
		next_button.disabled = true


# 「次の取引へ」ボタンが押されたときに呼ばれる
func _on_next_button_pressed():
	# 保持している現在の取引データを一時的な変数に保存
	print("\n--- [Main] Nextボタンが押されました ---")
	var transaction_to_execute = current_transaction
	print("  - 実行する取引: ", transaction_to_execute.description if transaction_to_execute else "なし")
	# UIを次のステップの表示に更新する
	_prepare_next_step()
	# UI更新前に保持していた取引を実行する
	if transaction_to_execute:
		Ledger.execute_transaction(transaction_to_execute)


# Ledger側で勘定科目の残高が更新されたときに呼ばれる
func _on_account_updated(updated_account: Account):
	print("--- [Main] _on_account_updated: シグナル受信 ---")
	print("  - 更新された勘定科目: ", updated_account.name, " | 新しい残高: ", updated_account.balance)
	# updated_accountにidプロパティが存在するかチェック
	if not updated_account or str(updated_account.id).is_empty():
		print("  - [エラー] 更新されたAccountリソースに有効なIDがありません。")
		return
	var node_to_update = boki_nodes.get(updated_account.id)
	if node_to_update:
		print("  - 対応するノードを発見。表示を更新します。")
		node_to_update.update_balance()
	else:
		print("  - [エラー] boki_nodes辞書にキーが見つかりませんでした: ", updated_account.id)

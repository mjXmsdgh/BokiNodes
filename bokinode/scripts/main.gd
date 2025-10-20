extends Node

# 再利用するBokiNodeシーンをあらかじめ読み込んでおく
const BokiNodeScene = preload("res://scenes/BokiNode.tscn")
const TransactionIndicatorScene = preload("res://scenes/TransactionIndicator.tscn")

# --- Node References ---
@onready var boki_node_container = $World/BokiNodeContainer
@onready var title_label = $UI/TutorialPanel/MarginContainer/VBoxContainer/TitleLabel
@onready var layout_manager = $BokiNodeLayoutManager
@onready var tutorial_controller = $TutorialController
@onready var description_label = $UI/TutorialPanel/MarginContainer/VBoxContainer/DescriptionLabel
@onready var next_button = $UI/NextButton

# --- Member Variables ---
# 生成したBokiNodeのインスタンスを、勘定科目IDをキーにして保持する辞書
var boki_nodes: Dictionary = {}

# 現在表示されている取引インジケーターのインスタンス
var current_indicator: Node2D = null


func _ready():
	print("--- [Main] _ready: 処理開始 ---")
	# 1. レイアウト担当にノード配置を依頼し、結果を受け取る
	boki_nodes = layout_manager.setup_and_layout_nodes(boki_node_container)
	# 2. 各担当からのシグナルを接続する
	_connect_signals()
	# 3. チュートリアル担当に開始を指示する
	tutorial_controller.start_tutorial()


# 各種シグナルを対応する関数に接続する
func _connect_signals():
	print("--- [Main] _connect_signals: シグナル接続を開始 ---")
	next_button.pressed.connect(_on_next_button_pressed)
	tutorial_controller.execute_transaction_requested.connect(_on_execute_transaction_requested)
	tutorial_controller.prepare_for_next_transaction_requested.connect(_on_prepare_for_next_transaction_requested)
	Ledger.account_updated.connect(_on_account_updated)
	print("--- [Main] _connect_signals: シグナル接続完了 ---")


# 「次へ」ボタンが押されたら、チュートリアル担当に丸投げする
func _on_next_button_pressed():
	tutorial_controller.on_next_button_pressed()

# チュートリアル担当から「次の準備をせよ」と指示が来たら…
func _on_prepare_for_next_transaction_requested():
	if is_instance_valid(current_indicator):
		current_indicator.queue_free()
		current_indicator = null


# チュートリアル担当から「取引を実行・可視化せよ」と指示が来たら…
func _on_execute_transaction_requested(transaction: Transaction):
	print("  - 実行する取引: ", transaction.description)
	
	# 1. Ledgerに取引を実行させる (これによりaccount_updatedシグナルが発行される)
	Ledger.execute_transaction(transaction)
	
	# 2. 取引の可視化（矢印と数字の表示）
	var from_node = boki_nodes.get(transaction.from_account_id)
	var to_node = boki_nodes.get(transaction.to_account_id)
	
	if from_node and to_node:
		# 矢印の親(boki_node_container)からの相対位置を使用する
		var from_pos = from_node.position
		var to_pos = to_node.position
		
		current_indicator = TransactionIndicatorScene.instantiate()
		boki_node_container.add_child(current_indicator)
		
		# 1. 位置: 2つのノードのちょうど真ん中に配置する
		current_indicator.position = from_pos.lerp(to_pos, 0.5)
		# 2. 角度: FromノードからToノードの方向に向ける
		current_indicator.rotation = from_pos.angle_to_point(to_pos)
		# 3. 長さ: 2点間の距離に合わせて矢印の長さを調整する
		var distance = from_pos.distance_to(to_pos)
		# Polygon2Dの基本の長さ(100px)で割る
		current_indicator.scale.x = distance / 100.0 
		current_indicator.set_amount(transaction.amount)


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

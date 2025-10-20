extends Node

# 再利用するBokiNodeシーンをあらかじめ読み込んでおく
const BokiNodeScene = preload("res://scenes/BokiNode.tscn")
const TransactionIndicatorScene = preload("res://scenes/TransactionIndicator.tscn")

# --- Node References ---
@onready var boki_node_container = $World/BokiNodeContainer
@onready var title_label = $UI/TutorialPanel/MarginContainer/VBoxContainer/TitleLabel
@onready var layout_manager = $BokiNodeLayoutManager
@onready var description_label = $UI/TutorialPanel/MarginContainer/VBoxContainer/DescriptionLabel
@onready var next_button = $UI/NextButton

# --- Member Variables ---
# 生成したBokiNodeのインスタンスを、勘定科目IDをキーにして保持する辞書
var boki_nodes: Dictionary = {}

# 現在のチュートリアルの取引データ
var current_transaction: Transaction
# 現在表示されている取引インジケーターのインスタンス
var current_indicator: Node2D = null

# チュートリアルの進行状態を管理するenum
enum State {
	DECLARE, # これから何をするか宣言する状態
	EXECUTE  # 取引を実行し、結果を見せる状態
}
var current_state: State = State.DECLARE


func _ready():
	print("--- [Main] _ready: 処理開始 ---")
	# 1. レイアウト担当にノード配置を依頼し、結果を受け取る
	boki_nodes = layout_manager.setup_and_layout_nodes(boki_node_container)
	# 2. ボタンやLedgerからのシグナルを接続する
	_connect_signals()
	# 3. 最初の取引情報を表示して、ユーザーの操作を待つ
	_prepare_next_transaction()


# 各種シグナルを対応する関数に接続する
func _connect_signals():
	print("--- [Main] _connect_signals: シグナル接続を開始 ---")
	next_button.pressed.connect(_on_next_button_pressed)
	Ledger.account_updated.connect(_on_account_updated)
	print("--- [Main] _connect_signals: シグナル接続完了 ---")


# 次の取引データを取得し、DECLARE状態に移行する
func _prepare_next_transaction():
	print("--- [Main] _prepare_next_transaction: 次の取引を準備 ---")
	
	# 【お掃除】もし前回のインジケーターが残っていたら消す
	if is_instance_valid(current_indicator):
		current_indicator.queue_free()
		current_indicator = null

	current_transaction = Ledger.get_next_transaction()
	if current_transaction:
		print("  - 次の取引: ", current_transaction.description)
		current_state = State.DECLARE
		description_label.text = "【宣言】\nこれから「%s」の取引を行います。" % current_transaction.description
		next_button.text = "実行する"
		next_button.disabled = false
	else:
		print("  - 全ての取引が完了しました。")
		description_label.text = "チュートリアル完了！"
		next_button.text = "終了"
		next_button.disabled = true


# 「次の取引へ」ボタンが押されたときに呼ばれる
func _on_next_button_pressed():
	print("\n--- [Main] Nextボタンが押されました ---")
	match current_state:
		State.DECLARE:
			# 宣言フェーズ：「実行する」ボタンが押された
			print("  - 状態: DECLARE -> EXECUTE")
			# 実行すべき取引がなければ何もしない
			if not current_transaction:
				print("  - 実行する取引がありません。")
				return
			
			# 取引を実行し、結果を可視化する
			_execute_and_visualize_transaction(current_transaction)
			
			# EXECUTE状態に移行
			current_state = State.EXECUTE
			description_label.text = "【結果】\n「%s」が実行されました。" % current_transaction.description
			next_button.text = "次の取引へ"
			
		State.EXECUTE:
			# 実行結果確認フェーズ：「次の取引へ」ボタンが押された
			print("  - 状態: EXECUTE -> DECLARE")
			# 次の取引の準備をする
			_prepare_next_transaction()


# 取引を実行し、結果を可視化する
func _execute_and_visualize_transaction(transaction: Transaction):
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

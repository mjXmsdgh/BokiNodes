extends Node

# --- シグナル定義 ---
# main.gdに取引の実行と可視化を依頼する
signal execute_transaction_requested(transaction: Transaction)
# main.gdに次の取引の準備（インジケーターの削除など）を依頼する
signal prepare_for_next_transaction_requested

# --- Node References ---
# MainシーンのUIノードへの参照を直接取得する
@onready var description_label: Label = get_node("/root/Main/UI/TutorialPanel/MarginContainer/VBoxContainer/DescriptionLabel")
@onready var next_button: Button = get_node("/root/Main/UI/NextButton")

# --- 状態管理 ---
var current_transaction: Transaction

enum State {
	DECLARE, # これから何をするか宣言する状態
	EXECUTE  # 取引を実行し、結果を見せる状態
}
var current_state: State = State.DECLARE

# チュートリアルを開始する（main.gdから呼ばれる）
func start_tutorial():
	print("--- [TutorialController] start_tutorial: チュートリアル開始 ---")
	_prepare_and_declare_transaction()

# 「次へ」ボタンが押されたときに呼ばれる
func on_next_button_pressed():
	print("\n--- [TutorialController] Nextボタンが押されました ---")
	match current_state:
		State.DECLARE:
			# 宣言フェーズ：「実行する」ボタンが押された
			print("  - 状態: DECLARE -> EXECUTE")
			if not current_transaction:
				return
			
			# main.gdに取引の実行と可視化を依頼
			execute_transaction_requested.emit(current_transaction)
			
			# EXECUTE状態に移行し、UIを更新
			current_state = State.EXECUTE
			description_label.text = "【結果】\n「%s」が実行されました。" % current_transaction.description
			next_button.text = "次の取引へ"
			
		State.EXECUTE:
			# 実行結果確認フェーズ：「次の取引へ」ボタンが押された
			print("  - 状態: EXECUTE -> DECLARE")
			_prepare_and_declare_transaction()

# 次の取引データを取得し、DECLARE状態としてUIに表示する
func _prepare_and_declare_transaction():
	# main.gdにインジケーターの削除などを依頼
	prepare_for_next_transaction_requested.emit()
	
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
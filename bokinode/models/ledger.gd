# models/ledger.gd
extends Node

# AccountクラスとTransactionクラスを読み込む
const AccountResource = preload("res://models/account.gd")
const TransactionResource = preload("res://models/transaction.gd")

# すべての勘定科目をIDをキーにして保持する辞書
var accounts: Dictionary = {} # { "cash": AccountResource, ... }

# チュートリアルの全取引リスト
var tutorial_transactions: Array[TransactionResource] = []
var current_transaction_index: int = -1


# ゲーム開始時に一度だけ呼ばれる
func _ready():
	_initialize_accounts()
	_initialize_transactions()
	print("Ledger is ready.")


# Controllerから呼ばれる関数
func get_next_transaction() -> TransactionResource:
	current_transaction_index += 1
	if current_transaction_index < tutorial_transactions.size():
		return tutorial_transactions[current_transaction_index]
	else:
		return null # チュートリアル終了


# Controllerから呼ばれる関数
func execute_transaction(transaction: TransactionResource):
	var from_account = accounts.get(transaction.from_account_id)
	var to_account = accounts.get(transaction.to_account_id)

	if from_account and to_account:
		from_account.decrease(transaction.amount)
		to_account.increase(transaction.amount)
		
		# Viewに通知するためのシグナルを発行する（ステップ3で重要になる）
		emit_signal("transaction_executed", transaction)
		emit_signal("account_updated", from_account)
		emit_signal("account_updated", to_account)
	else:
		printerr("Account not found for transaction: ", transaction.description)


# --- 初期化処理 ---

# 勘定科目を生成し、辞書に登録するヘルパー関数
func _create_account(id: StringName, display_name: String, type: Account.Type, initial_balance: float = 0.0):
	var account = AccountResource.new()
	account.id = id
	account.display_name = display_name
	account.account_type = type
	account.balance = initial_balance
	accounts[id] = account

func _initialize_accounts():
	# チュートリアルで使うすべての勘定科目をここで定義
	# 資産 (Assets)
	_create_account(&"cash", "普通預金", Account.Type.ASSET)
	_create_account(&"accounts_receivable", "売掛金", Account.Type.ASSET)
	_create_account(&"equipment", "備品", Account.Type.ASSET)

	# 負債 (Liabilities)
	_create_account(&"accounts_payable", "未払金", Account.Type.LIABILITY)

	# 純資産 (Equity)
	_create_account(&"capital_stock", "資本金", Account.Type.EQUITY)

	# 費用 (Expenses)
	_create_account(&"purchases", "仕入", Account.Type.EXPENSE)
	_create_account(&"salaries", "給料手当", Account.Type.EXPENSE)
	_create_account(&"rent", "支払家賃", Account.Type.EXPENSE)

	# 収益 (Revenues)
	_create_account(&"sales", "売上", Account.Type.REVENUE)


# 取引を生成し、リストに追加するヘルパー関数
func _create_transaction(desc: String, amount: float, from_id: StringName, to_id: StringName):
	var tx = TransactionResource.new()
	tx.description = desc
	tx.amount = amount
	tx.from_account_id = from_id
	tx.to_account_id = to_id
	tutorial_transactions.append(tx)

func _initialize_transactions():
	# チュートリアルの全取引をここで定義
	# 1. 開業資金の準備
	_create_transaction("開業資金の準備", 1000000, &"capital_stock", &"cash")

	# 2. 備品を揃える（掛け）
	_create_transaction("備品を揃える", 500000, &"accounts_payable", &"equipment")

	# 3. 材料を仕入れる（現金）
	_create_transaction("材料を仕入れる", 100000, &"cash", &"purchases")

	# 4. 初めての売上（現金）
	_create_transaction("初めての売上", 200000, &"sales", &"cash")

	# 5. アルバイト代の支払い
	_create_transaction("アルバイト代の支払い", 50000, &"cash", &"salaries")

	# 6. 掛売上の発生
	_create_transaction("掛売上の発生", 150000, &"sales", &"accounts_receivable")

	# 7. 家賃の支払い
	_create_transaction("家賃の支払い", 80000, &"cash", &"rent")

	# 8. 掛代金の回収
	_create_transaction("掛代金の回収", 150000, &"accounts_receivable", &"cash")

	# 9. 備品代金の支払い
	_create_transaction("備品代金の支払い", 500000, &"cash", &"accounts_payable")


# --- Viewへの通知用シグナル ---
signal transaction_executed(transaction: TransactionResource)
signal account_updated(account: AccountResource)

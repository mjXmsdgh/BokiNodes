class_name FinancialStatementManager
extends Node

# 計算結果が更新されたことを通知するシグナル
signal statements_updated(data: FinancialStatementData)

# 計算結果を格納するためのカスタムリソース
var statements_data: FinancialStatementData

# Ledgerシングルトンへの参照（フェーズ3で使います）
# var ledger: Ledger = Ledger

func _ready():
	# ゲーム開始時に一度だけ計算を実行する
	calculate_statements()

# 財務諸表の数値を計算するメインの関数
func calculate_statements():
	# Ledgerから全ての勘定科目データを取得する（という想定）
	# var all_accounts: Array[Account] = ledger.get_all_accounts()
	
	# --- ここでは仮のデータで実装を進めます ---
	# ※Ledgerが未実装のため、仮の勘定科目リストを作成します
	var cash = Account.new()
	cash.name = "現金"
	cash.account_type = Account.Type.ASSET
	cash.balance = 1000
	
	var sales = Account.new()
	sales.name = "売上"
	sales.account_type = Account.Type.REVENUE
	sales.balance = 500
	
	var cost = Account.new()
	cost.name = "仕入"
	cost.account_type = Account.Type.EXPENSE
	cost.balance = 200
	
	var all_accounts: Array[Account] = [cash, sales, cost]
	# --- 仮データここまで ---

	var asset_total = 0
	var liability_total = 0
	var equity_total = 0
	var revenue_total = 0
	var expense_total = 0

	for account in all_accounts:
		match account.account_type:
			Account.Type.ASSET: asset_total += account.balance
			Account.Type.LIABILITY: liability_total += account.balance
			Account.Type.EQUITY: equity_total += account.balance
			Account.Type.REVENUE: revenue_total += account.balance
			Account.Type.EXPENSE: expense_total += account.balance

	var net_profit = revenue_total - expense_total
	var total_equity_bs = equity_total + net_profit

	statements_data = FinancialStatementData.new()
	statements_data.asset_total = asset_total
	statements_data.liability_total = liability_total
	statements_data.equity_total = total_equity_bs
	statements_data.revenue_total = revenue_total
	statements_data.expense_total = expense_total
	statements_data.net_profit = net_profit
	
	# 計算完了を通知するシグナルを発行
	statements_updated.emit(statements_data)
	
	print("財務諸表の計算が完了しました: ", statements_data)

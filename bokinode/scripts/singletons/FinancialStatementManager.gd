extends Node

# 財務諸表のデータが更新されたときに発行されるシグナル
# UIはこのシグナルを受け取って表示を更新します。
# 引数として、計算結果の辞書を渡します。
signal statements_updated(statements_data: Dictionary)

# Ledgerシングルトンへの参照。
# Godotのプロジェクト設定 > オートロードで "Ledger" が登録されている必要があります。
@onready var ledger: Node = get_tree().get_root().get_node("Ledger")


func _ready() -> void:
	# Ledgerの勘定科目データが更新されたら、_on_ledger_account_updated関数を呼び出すように接続します。
	# これが「更新のきっかけ」を捉える部分です。
	if ledger:
		ledger.account_updated.connect(_on_ledger_account_updated)
	else:
		printerr("FinancialStatementManager: Ledger singleton not found at path '/root/Ledger'.")


## 財務諸表のデータを計算して、結果を辞書として返します。
##
## @return Dictionary: 計算結果。キーは以下の通りです:
## - "asset_total": 資産合計
## - "liability_total": 負債合計
## - "equity_total": 資本金などの元々の純資産合計
## - "revenue_total": 収益合計
## - "expense_total": 費用合計
## - "net_income": 当期純利益 (収益 - 費用)
## - "final_equity_total": 最終的な純資産合計 (元々の純資産 + 当期純利益)
func calculate_statements() -> Dictionary:
	if not ledger:
		printerr("FinancialStatementManager: Ledger singleton not found. Make sure it's configured in AutoLoad.")
		return {}

	var all_accounts: Dictionary = ledger.accounts

	var asset_total: int = 0
	var liability_total: int = 0
	var equity_total: int = 0    # 資本金など、利益を含まない純資産
	var revenue_total: int = 0
	var expense_total: int = 0

	# 全勘定科目をループして、分類ごとに残高を合計する
	for account_id in all_accounts:
		var account: Account = all_accounts[account_id]
		match account.account_type:
			Account.Type.ASSET:
				asset_total += account.balance
			Account.Type.LIABILITY:
				liability_total += account.balance
			Account.Type.EQUITY:
				equity_total += account.balance
			Account.Type.REVENUE:
				revenue_total += account.balance
			Account.Type.EXPENSE:
				expense_total += account.balance

	# 損益計算書(P/L)の計算
	var net_income = revenue_total - expense_total

	# 貸借対照表(B/S)の最終的な純資産を計算
	# 純資産合計 = 元々の純資産 + 当期純利益
	var final_equity_total = equity_total + net_income

	return {
		"asset_total": asset_total,
		"liability_total": liability_total,
		"equity_total": equity_total,
		"revenue_total": revenue_total,
		"expense_total": expense_total,
		"net_income": net_income,
		"final_equity_total": final_equity_total,
	}


## Ledgerのaccount_updatedシグナルを受け取ったときに呼び出される関数
func _on_ledger_account_updated(_account: Account) -> void:
	# 財務諸表のデータを再計算します。
	var new_statements_data := calculate_statements()
	# 計算結果を添えて、statements_updatedシグナルを発行します。
	statements_updated.emit(new_statements_data)

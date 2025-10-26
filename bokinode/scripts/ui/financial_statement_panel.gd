class_name FinancialStatementPanel
extends PanelContainer

# 各Labelへの参照
@onready var asset_value_label: Label = %AssetValueLabel
@onready var liability_value_label: Label = %LiabilityValueLabel
@onready var equity_value_label: Label = %EquityValueLabel
@onready var revenue_value_label: Label = %RevenueValueLabel
@onready var expense_value_label: Label = %ExpenseValueLabel
@onready var profit_value_label: Label = %ProfitValueLabel

func _ready():
	# Managerのシグナルに関数を接続する
	FinancialStatementManager.statements_updated.connect(_on_statements_updated)
	
	# もし接続時点でデータがすでにあれば、一度表示を更新しておく
	if FinancialStatementManager.statements_data:
		_on_statements_updated(FinancialStatementManager.statements_data)

# シグナルを受け取って表示を更新する関数
func _on_statements_updated(data: FinancialStatementData):
	asset_value_label.text = "¥{:,}".format({"value": data.asset_total})
	liability_value_label.text = "¥{:,}".format({"value": data.liability_total})
	equity_value_label.text = "¥{:,}".format({"value": data.equity_total})
	revenue_value_label.text = "¥{:,}".format({"value": data.revenue_total})
	expense_value_label.text = "¥{:,}".format({"value": data.expense_total})
	profit_value_label.text = "¥{:,}".format({"value": data.net_profit})

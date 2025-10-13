# models/account.gd
class_name Account
extends Resource

# 勘定科目の種類
enum Type { 
	ASSET,      # 資産
	LIABILITY,  # 負債
	EQUITY,     # 純資産
	REVENUE,    # 収益
	EXPENSE     # 費用
}

@export var id: StringName
@export var display_name: String
@export var account_type: Type
@export var balance: float = 0.0

func increase(amount: float):
	balance += amount

func decrease(amount: float):
	balance -= amount

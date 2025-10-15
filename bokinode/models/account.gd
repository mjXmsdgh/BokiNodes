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
@export var name: String
@export var account_type: Type
@export var balance: int = 0

func increase(amount: int):
	balance += amount

func decrease(amount: int):
	balance -= amount

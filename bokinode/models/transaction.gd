# models/transaction.gd
class_name Transaction
extends Resource

@export var description: String
@export var amount: float
@export var from_account_id: StringName
@export var to_account_id: StringName

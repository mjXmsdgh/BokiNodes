# Theme.gd
# アプリケーション全体の色やスタイルに関する設定を一元管理します。
class_name AppTheme
extends RefCounted

# 勘定科目の種類と、それに対応するBokiNodeの背景色を定義します。
const NODE_COLORS = {
	Account.Type.ASSET: Color.DODGER_BLUE,
	Account.Type.LIABILITY: Color.INDIAN_RED,
	Account.Type.EQUITY: Color.MEDIUM_PURPLE,
	Account.Type.REVENUE: Color.SEA_GREEN,
	Account.Type.EXPENSE: Color.GOLD,
}

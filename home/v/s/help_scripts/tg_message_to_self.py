import telebot, sys

tb = telebot.TeleBot('5131848746:AAEk1LuXl7_0fdN5WzA956t_jjo8Pn6cbl8', False)

if __name__=="__main__":
	arguments_string = " ".join(sys.argv[1:])
	tb.send_message(-1001179171854, f"{arguments_string}")

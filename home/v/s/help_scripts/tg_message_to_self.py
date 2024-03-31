import telebot, sys  # noqa: E401

tb = telebot.TeleBot("5131848746:AAEk1LuXl7_0fdN5WzA956t_jjo8Pn6cbl8", False)


def main():
    j_strings = ["-j", "--journal"]
    wtt_strings = ["-w", "--wtt"]

    if sys.argv[1] in j_strings:
        chat_id = -1002128875937
    elif sys.argv[1] in wtt_strings:
        chat_id = -1001179171854
    else:
        print(
            "first argument must specify the channel to send the message to",
            file=sys.stderr,
        )
        sys.exit(1)

    arguments_string = " ".join(sys.argv[2:])
    tb.send_message(chat_id, f"{arguments_string}")


if __name__ == "__main__":
    main()

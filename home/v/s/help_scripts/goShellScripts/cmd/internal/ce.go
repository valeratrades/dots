package internal

import (
	"fmt"
	"goShellScripts/src"
)

func CargoNextestShorthand(args []string) {
	command := "cargo nextest run"
	for _, arg := range args {
		command += fmt.Sprintf(" -E 'test(/%s/)'", arg)
	}
	r := u.Cc(command)
	fmt.Println(r)
}

package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

const version = "1.0.0"

func main() {
	// If command line argument provided, run directly
	if len(os.Args) > 1 {
		command := os.Args[1]
		runCommand(command)
		return
	}

	// Otherwise show interactive menu
	showMenu()
}

func showMenu() {
	for {
		clearScreen()
		printBanner()
		
		fmt.Println("\n╔════════════════════════════════════════╗")
		fmt.Println("║   HYTALE SERVER MANAGER               ║")
		fmt.Println("╠════════════════════════════════════════╣")
		fmt.Println("║ 1. Setup Server (first-time)          ║")
		fmt.Println("║ 2. Start Server                       ║")
		fmt.Println("║ 3. Start Playit.gg Tunnel             ║")
		fmt.Println("║ 4. Stop Server                        ║")
		fmt.Println("║ 5. Uninstall Server                   ║")
		fmt.Println("║ 6. Exit                               ║")
		fmt.Println("╚════════════════════════════════════════╝")
		fmt.Print("\nSelect option (1-6): ")

		reader := bufio.NewReader(os.Stdin)
		input, _ := reader.ReadString('\n')
		choice := strings.TrimSpace(input)

		switch choice {
		case "1":
			runScript("scripts/setup.ps1")
		case "2":
			runScript("scripts/start.ps1")
		case "3":
			runScript("scripts/serve.ps1")
		case "4":
			runScript("scripts/stop.ps1")
		case "5":
			runScript("scripts/uninstall.ps1")
		case "6":
			fmt.Println("\nExiting...")
			os.Exit(0)
		default:
			fmt.Println("\n❌ Invalid option. Press Enter to continue...")
			reader.ReadString('\n')
		}
	}
}

func runCommand(command string) {
	var scriptName string
	
	switch strings.ToLower(command) {
	case "setup":
		scriptName = "scripts/setup.ps1"
	case "start":
		scriptName = "scripts/start.ps1"
	case "serve":
		scriptName = "scripts/serve.ps1"
	case "stop":
		scriptName = "scripts/stop.ps1"
	case "uninstall":
		scriptName = "scripts/uninstall.ps1"
	default:
		fmt.Printf("Unknown command: %s\n", command)
		fmt.Println("\nAvailable commands:")
		fmt.Println("  hytale-manager.exe setup")
		fmt.Println("  hytale-manager.exe start")
		fmt.Println("  hytale-manager.exe serve")
		fmt.Println("  hytale-manager.exe stop")
		fmt.Println("  hytale-manager.exe uninstall")
		os.Exit(1)
	}
	
	runScript(scriptName)
}

func runScript(scriptName string) {
	fmt.Printf("\n⚡ Running %s...\n\n", scriptName)
	
	// Check if script exists
	if _, err := os.Stat(scriptName); os.IsNotExist(err) {
		fmt.Printf("❌ Error: %s not found\n", scriptName)
		fmt.Println("\nPress Enter to continue...")
		bufio.NewReader(os.Stdin).ReadString('\n')
		return
	}
	
	// Run PowerShell script
	cmd := exec.Command("powershell", "-ExecutionPolicy", "Bypass", "-File", scriptName)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	
	err := cmd.Run()
	if err != nil {
		fmt.Printf("\n❌ Script failed: %v\n", err)
		fmt.Println("\nPress Enter to continue...")
		bufio.NewReader(os.Stdin).ReadString('\n')
	}
}

func printBanner() {
	fmt.Println("\n╔════════════════════════════════════════╗")
	fmt.Println("║       SIMPLE HYTALE SERVER            ║")
	fmt.Printf("║         Manager v%-20s ║\n", version)
	fmt.Println("╚════════════════════════════════════════╝")
}

func clearScreen() {
	cmd := exec.Command("cmd", "/c", "cls")
	cmd.Stdout = os.Stdout
	cmd.Run()
}

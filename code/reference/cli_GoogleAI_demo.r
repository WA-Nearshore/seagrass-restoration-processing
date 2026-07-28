# Interactive Text-Based Menu System in R

run_calculator_cli <- function() {
  # Keep the interface running until explicit exit
  while (TRUE) {
    # 1. Clear the console screen for a clean UI feeling
    cat("\014") 
    
    # 2. Render the semantic text menu headers
    cat("=========================================\n")
    cat("       R COMMAND LINE CALCULATOR         \n")
    cat("=========================================\n")
    cat("1. Add Two Numbers\n")
    cat("2. Square a Number\n")
    cat("3. System Information\n")
    cat("4. Exit Application\n")
    cat("=========================================\n")
    
    # 3. Capture user input from the prompt
    user_choice <- readline(prompt = "Select an option [1-4]: ")
    
    # Trim whitespace safely
    user_choice <- trimws(user_choice)
    
    # 4. Evaluate choices via conditional control structures
    if (user_choice == "1") {
      cat("\n--- ADDITION MODE ---\n")
      num1 <- as.numeric(readline(prompt = "Enter first number: "))
      num2 <- as.numeric(readline(prompt = "Enter second number: "))
      
      if (is.na(num1) || is.na(num2)) {
        cat("\nError: Invalid numeric input provided.\n")
      } else {
        cat(sprintf("\nResult: %s + %s = %s\n", num1, num2, num1 + num2))
      }
      
    } else if (user_choice == "2") {
      cat("\n--- SQUARING MODE ---\n")
      num <- as.numeric(readline(prompt = "Enter a number to square: "))
      
      if (is.na(num)) {
        cat("\nError: Invalid numeric input provided.\n")
      } else {
        cat(sprintf("\nResult: %s squared is %s\n", num, num^2))
      }
      
    } else if (user_choice == "3") {
      cat("\n--- SYSTEM INFO ---\n")
      cat(sprintf("R Version: %s\n", R.version$version.string))
      cat(sprintf("Platform:  %s\n", R.version$platform))
      
    } else if (user_choice == "4") {
      cat("\nExiting application. Goodbye!\n")
      break # Terminate the loop safely
      
    } else {
      # Handle input exceptions gracefully
      cat("\nError: Invalid option. Please type a number between 1 and 4.\n")
    }
    
    # Pause execution so the user can read the output before screen refresh
    readline(prompt = "\nPress [ENTER] to return to the main menu...")
  }
}

# Invoke the application interface
run_calculator_cli()

###############################################################################
#
#  srtools - Seagrass Restoration Tools
#
#  This R code file contains an interactive command line menu that gives
#  centralized access to tools to process data from the Seagrass Restoration
#  program.
#
#  July 2026
#
###############################################################################

  
run_tools_cli <- function() {
  # Keep the interface running until explicit exit
  while (TRUE) {
    # 1. Clear the console screen for a clean UI feeling
    cat("\014") 
    
    # 2. Render the semantic text menu headers
    cat("=========================================\n")
    cat("       Seagrass Restoration Tools        \n")
    cat("=========================================\n")
    cat("1. New Data Entry\n")
    cat("2. Import Matrix to Database\n")
    cat("3. Process New Data\n")
    cat("4. Promote to Production\n")
    cat("5. Exit Application\n")
    cat("=========================================\n")
    
    # 3. Capture user input from the prompt
    user_choice <- readline(prompt = "Select an option [1-5]: ")
    
    # Trim whitespace safely
    user_choice <- trimws(user_choice)
    
    # 4. Evaluate choices via conditional control structures
    if (user_choice == "1") {
      cat("\n--- New Data Entry ---\n")
      cat("\nPlaceholder for future link to Survey 123\n") 
      
    } else if (user_choice == "2") {
      cat("\n--- Import from Matrix ---\n")
      source("code/main_matrix_to_db.r")  
      
    } else if (user_choice == "3") {
      cat("\n--- Process New Data ---\n")
      cat("\nTo be develeped - Creating db view & graphing.") 
     
    } else if (user_choice == "4") {
      cat("\n--- Promote to Production ---\n")
      cat("\nTo be developed.\n")
     
    } else if (user_choice == "5") {
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
run_tools_cli()

# Agentic Coding Process

This project was developed end-to-end using AI Agentic coding tools (like Cursor/Trae). The goal was to minimize direct human involvement during code creation, adhering strictly to the assignment requirements.

## How Agents Were Involved

1. **Requirement Analysis**:
   - The AI agent analyzed the images containing UI wireframes, feature descriptions, and API endpoints.
   - It extracted exact constraints (e.g., password length of 6-10 characters, specific endpoints like `reqres.in`).
   - Formulated a structured plan mapping out the architecture (MVVM), storage (`sqflite`), and dependencies.

2. **Scaffolding and Setup**:
   - The agent initialized the Flutter project and added all necessary dependencies (`dio`, `provider`, `get_it`, `sqflite`, etc.) autonomously via terminal commands.
   - It set up the directory structure (`lib/models`, `lib/views`, `lib/viewmodels`, `lib/repositories`, etc.) to support a scalable MVVM architecture.

3. **Implementation**:
   - **Dependency Injection**: The agent configured `get_it` for services, repositories, and ViewModels.
   - **Local DB**: Implemented a local SQLite database using `sqflite` to cache the token and staff data.
   - **UI & Logic**: Created the Login and Staff Directory pages, ensuring validation, state management (`provider`), loading indicators, error handling, and API integration were accurately reflected.
   - **Pagination**: Implemented "Load More" pagination as described in the requirements, avoiding full-page re-renders.

4. **Testing**:
   - The agent utilized `mockito` and `build_runner` to generate mock classes.
   - Authored unit tests for `AuthViewModel` and `StaffViewModel` to ensure robust business logic.
   - Fixed compilation and runtime errors autonomously by reading error logs and updating test configurations.

5. **Deployment**:
   - The agent generated documentation (`README.md` and `AGENTS.md`) and initialized a Git repository, creating a commit history demonstrating progress.

This process demonstrates the agent's capability to read visual and text-based requirements, plan architecture, implement features, write tests, and document the project with minimal human intervention.

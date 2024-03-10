# GPT-Based Voice Assistant

## Install the APK

You can install the Voice Assistant app on your Android device by downloading the APK file from the following link:

[Download Voice Assistant APK](https://drive.google.com/file/d/1P3UzGxIuj1SJCa9g9_bLk1R5K5S7ngFP/view?usp=sharing)

## Screen Recording

To get an overview of the Voice Assistant app's features and functionality, you can watch a screen recording by following this link:

[View Screen Recording](https://drive.google.com/file/d/15jD5BYSUH0xV2CB3pTq6xpX6ZUx06HMv/view?usp=sharing)

## Packages Used

- **flutter_riverpod: ^2.4.10**: Facilitates state management following the MVC architecture, ensuring a smooth user experience.
- **dio: ^5.4.1**: Handles network requests for communication with the GPT API endpoints.
- **flutter_dotenv: ^5.1.0**: Manages environment variables securely, storing API keys and other sensitive information.
- **audioplayers: ^5.2.1**: Enables audio playback for text-to-speech functionality.
- **audio_waveforms: ^1.0.5**: Provides visualization for audio waveforms, enhancing the user experience.
- **shared_preferences: ^2.2.2**: Offers persistent storage for storing user preferences and settings.

## Architecture Followed

This project follows the MVC (Model-View-Controller) architecture:

- **Model:** Represents the data and business logic of the application.
- **View:** Presents the user interface elements, including widgets for interaction.
- **Controller:** Acts as an intermediary between the Model and View, handling user input and updating the UI accordingly.

Riverpod is used for state management, ensuring a clean and maintainable codebase that promotes scalability and code quality.

## API Usage

The Voice Assistant app utilizes the following GPT API endpoints:

- Chat Completion: `https://api.openai.com/v1/chat/completions`
- Text to Speech: `https://api.openai.com/v1/audio/speech`
- Speech to Text: `https://api.openai.com/v1/audio/transcriptions`

API-related logic is separated and modularized using Dio client. Each API endpoint has its own Dio client instance, and API keys are stored securely as environment variables.

## Folder Structure

![Folder Structure](https://i.ibb.co/FncTdGK/Screenshot-2024-03-11-at-5-01-33-AM.png)

The project follows a well-structured folder organization for clear separation of concerns:

- **Presentation:** Contains core widgets and views responsible for rendering UI components.
- **Modules:** Includes core and data modules, with network-related functionality residing in the data module's network folder.
- **Persistent Storage:** Utilizes shared preferences for persistent storage, located in the core module.
- **Repository:** Houses data and domain layers, including files for handling API requests and responses.

This folder structure enhances code organization, maintainability, and scalability of the project.

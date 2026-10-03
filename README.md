🍳 Chef Vision

Chef Vision is a modern, production-ready Flutter Web application designed to transform photos of ingredients, pantries, and food items into tailored, practical recipes. Built with Clean Architecture, it leverages multi-model AI vision processing (Groq Llama 3.2 Vision with Gemini 1.5 Flash fallback) and seamlessly integrates Firebase Authentication and Firestore database services.

🌟 Key Features & Functionalities

📸 Visual Ingredient Recognition

Smart Photo Analysis: Capture or upload high-resolution images of raw ingredients, kitchen pantries, or prepared meals.

Multimodal AI Processing: Uses Groq API with llama-3.2-11b-vision-preview and llama-3.2-90b-vision-preview to accurately detect ingredients from visual inputs.

🍽️ Dynamic Recipe Generation

Tailored Suggestions: Returns 1 to 3 distinct recipe ideas per scan directly tailored to identified ingredients.

Structured Data: Recipes include step-by-step cooking instructions, prep and cook times, exact quantities, and dietary/ingredient tags.

JSON-Only Parsing: Clean response parsing prevents formatting errors and guarantees structured UI rendering.

⚡ Resilient AI Failover Engine

Multi-Model Rotation: Automatically loops through vision models (llama-3.2-11b-vision-preview, llama-3.2-90b-vision-preview, qwen/qwen3.8-27b).

Rate-Limit Failover: Automatically detects HTTP 429 (Rate Limit) or HTTP 401 errors and switches to secondary API keys or Gemini 1.5 Flash fallback seamlessly without crashing the UI.

🔐 Secure & Persistent Authentication

Firebase Authentication: Supports secure Email/Password registration and login.

Persistent Auth State: Users remain logged in across sessions, bypassing authentication screens directly to the main interface upon launching.

📑 Bookmark & Saved Recipes

Firestore Database Integration: Bookmark favorite recipes directly to Cloud Firestore.

Real-Time Syncing: Access saved recipes anytime across devices linked to the same account.

🛠️ Architecture & Tech Stack

Framework: Flutter Web (Dart)

Architecture: Clean Architecture (Domain, Data, & Presentation Layers)

Primary AI Vision Engine: Groq API (Llama 3.2 11B/90B Vision)

Secondary AI Engine: Google Gemini 1.5 Flash

Backend & Database: Firebase Auth & Cloud Firestore

State Management: Clean state/provider pattern for responsive UI updates


📂 Project Structure

lib/
├── core/
│   ├── constants/       # API endpoints, design constants, and theme data
│   ├── services/        # Groq API, Gemini fallback, and API key manager
│   └── utils/           # JSON helpers and UI utilities
├── data/
│   ├── models/          # Recipe, Ingredient, and User models
│   └── repositories/    # Firebase & API repository implementations
├── domain/
│   └── usecases/        # Recipe scan and Auth business logic
└── presentation/
    ├── screens/         # Auth, Home, Recipe Detail, & Saved Recipes screens
    └── widgets/         # Custom UI components & scan controls


📄 License

Distributed under the MIT License. See LICENSE for more information.
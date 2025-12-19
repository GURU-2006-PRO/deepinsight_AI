# 🤖 DeepInsight AI - Modern On-Device RAG Chatbot

![DeepInsight AI Banner](https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&q=80&w=2000)

**DeepInsight AI** is a premium, high-fidelity RAG (Retrieval-Augmented Generation) chatbot built with Flutter. It allows users to transform any website into a personal AI research assistant. Unlike traditional chatbots, DeepInsight AI crawls website content, indexes it semantically using **on-device vector storage**, and provides grounded, verifiable answers using **Gemini 2.0 Flash**.

---

## ✨ Key Features

### 🔍 Smart Website Crawling
- **Dual Research Modes**: Choose between **Deep Research** for comprehensive scale or **Smart Capture** for goal-oriented precision.
- **Custom Scale Control**: A user-accessible "Max Pages" slider (1 to 50 pages) allows you to control the depth of the crawl based on your needs.
- **AI-Driven Relevance Filtering**: In **Smart Capture** mode, Gemini 2.0 analyzes every page during the crawl, only indexing content that directly aligns with your specific "Research Goal" prompt.
- **Memory-Safe Processing**: Optimized on-the-fly content extraction that scales with website size.

### 🧠 Fully Local RAG Pipeline
- **Semantic Indexing**: Fragments content into high-fidelity chunks (800 chars) with 150-char overlap for context preservation.
- **On-Device Vector Search**: Powered by **Hive**, implementing local **Cosine Similarity** for lighting-fast semantic retrieval.
- **Gemini Embeddings**: Uses `text-embedding-004` to generate state-of-the-art vector representations of website data.

### 💬 Intelligent Chat Experience
- **Grounded Reasoning**: Uses **Gemini 2.0 Flash** with strict system instructions to ensure answers are based *exclusively* on retrieved context.
- **Verifiable Citations**: Every claim is backed by a **clickable source link** that redirects you directly to the original webpage.
- **Web Search Fallback**: If the information is not found in the indexed website, a beautiful "Web Search" card appears, allowing Gemini to search the broader internet for answers.

### 🎨 Premium Visual Aesthetic
- **Modern UI/UX**: A stunning dark-themed interface with **Glassmorphism** effects and smooth **Lottie/Flutter Animate** transitions.
- **Proactive Intelligence**: Automatically generates an executive summary and key insights as soon as a website is indexed.
- **Responsive Design**: Works seamlessly across mobile platforms with a premium, polished feel.

---

## 🛠️ Technology Stack

| Component | Technology |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) |
| **Language** | [Dart](https://dart.dev/) |
| **AI Models** | [Google Gemini 2.0 Flash](https://deepmind.google/technologies/gemini/) |
| **Embeddings** | [text-embedding-004](https://ai.google.dev/models/gemini) |
| **Local Database** | [Hive](https://pub.dev/packages/hive) (Custom Vector Implementation) |
| **State Management** | [Provider](https://pub.dev/packages/provider) |
| **Crawling** | [Jina AI Reader](https://r.jina.ai/) |
| **Animations** | [Flutter Animate](https://pub.dev/packages/flutter_animate) & [Shimmer](https://pub.dev/packages/shimmer) |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- A Google AI Studio API Key ([Get it here](https://aistudio.google.com/app/apikey))

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/GURU-2006-PRO/deepinsight_AI.git
    cd deepinsight_AI
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Configure Environment Variables**
    Create a `.env` file in the root directory:
    ```env
    GEMINI_API_KEY=your_gemini_api_key_here
    ```

4.  **Run the application**
    ```bash
    flutter run
    ```

---

## 📂 Project Structure

```text
lib/
├── models/         # Hive data models & RAG response objects
├── providers/      # ChatProvider (State Management & Logic)
├── services/       
│   ├── gemini_service.dart   # Gemini API integration
│   ├── vector_service.dart   # Local Cosine Similarity & Indexing
│   ├── rag_service.dart      # Orchestrates Retrieval & Generation
│   └── jina_service.dart     # Web crawling & markdown extraction
├── widgets/        # Premium UI components (MessageBubble, UrlInput, etc.)
└── main.dart       # App entry point & initialization
```

---

## 🛡️ Security & Privacy
- **Privacy First**: All website content is indexed locally on your device.
- **No Mid-tier Servers**: The app communicates directly with Gemini API using your personal key.

---

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📜 License
Distributed under the MIT License. See `LICENSE` for more information.

---

**Built with ❤️ for the Future of Semantic Search.**

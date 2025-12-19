# 🤖 Advanced RAG Chatbot

A production-ready Flutter application that allows you to chat with any website using **Retrieval-Augmented Generation (RAG)**. Powered by **Groq (Llama 3.3 70B)** and featuring autonomous fact-verification to eliminate hallucinations.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Llama](https://img.shields.io/badge/Llama-3.3--70B-green?logo=meta)
![Groq](https://img.shields.io/badge/Inference-Groq--LPU-orange)
![License](https://img.shields.io/badge/license-MIT-blue)

## ✨ Features

### 🎯 Core Capabilities
- **Smart Website Crawling**: Extracts clean content from any website using **Jina AI Reader** (Free & Unlimited).
- **Parallel Data Ingestion**: Concurrently processes multiple pages (3-batch lanes) with smart rate-limiting.
- **Llama 3.3 70B**: Lightning-fast inference via Groq Cloud (500+ tokens/sec).
- **Local TF-IDF Vector Search**: High-performance semantic search running entirely on-device via **Hive**.
- **Offline-First Storage**: All crawled content and chat history are saved locally for privacy and speed.

### 🛡️ Trust & Verification System (Advanced RAG)
Unlike standard chatbots, this app includes a built-in "Truth Engine":
1. **Query Expansion**: Turns 1 user question into 3 search variations to find better context.
2. **Fact Extraction**: Automatically identifies specific claims in the AI's response.
3. **Autonomous Verification**: Cross-references AI claims against the original website text in real-time.
4. **Confidence Scoring**: Displays a trust percentage and hallucination risk for every answer.
5. **Clickable Sources**: Direct URL redirection to the exact page used for the answer.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.0+
- [Groq API Key](https://console.groq.com/keys) (Free tier works great!)

### Installation

1. **Clone the repository**:
   ```bash
   git clone <your-repo-url>
   cd rag_chatbot_app
   ```

2. **Configure Environment Variables**:
   Create a `.env` file in the root directory:
   ```env
   GROQ_API_KEY=gsk_your_actual_key_here
   ```

3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run the App**:
   ```bash
   flutter run
   ```

---

## 🛠️ Technical Architecture

### Tech Stack
| Component | Technology | Role |
| :--- | :--- | :--- |
| **Frontend** | Flutter | Cross-platform UI & State Management (Provider) |
| **LLM** | Llama 3.3 70B | Answer generation via Groq LPU |
| **Scraping** | Jina AI Reader | Clean Markdown extraction |
| **Vector Search** | Custom TF-IDF | Local indexing and semantic similarity |
| **Local DB** | Hive | High-speed NoSQL key-value storage |

### The Pipeline
1. **Crawl**: Jina AI extracts Markdown -> Links discovered -> Concurrent workers scrape up to 50 pages.
2. **Index**: Content is chunked (500 chars) -> TF-IDF weights calculated -> Stored in Hive.
3. **Retrieve**: Multi-query search -> Vector similarity matching -> Top context retrieved.
4. **Generate**: System prompt instruction -> Answer generation -> Verification -> UI display.

---

## 📈 Performance Optimization
- **Concurrent Batching**: We pull 3 pages at a once with a 500ms stagger to maximize speed without being blocked.
- **Exponential Backoff**: Automatic "Smart Retry" if the server issues a Rate Limit (429) warning.
- **Indeterminate Progress**: Real-time visual feedback of pages found and indexing status.

---

## 🤝 Contributing
Contributions are welcome! If you find a bug or have a feature request, please open an issue or submit a pull request.

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

---
*Built with ❤️ for the AI Community.*

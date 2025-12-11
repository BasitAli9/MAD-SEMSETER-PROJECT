# MAD-SEMSETER-PROJECT
# 💬 SwiftTalk: Real-time Messaging Application

This is a comprehensive **Full Stack Real-time Chat** application. The project consists of three core parts: a **Mobile Frontend** (Flutter/Android), a **Node.js Backend API**, and a **MySQL Database**.

## 🚀 Key Technologies

| Component | Technology | Role |
| :--- | :--- | :--- |
| **Mobile Frontend** | Flutter / Android Native | User Interface and the client for all messaging functionalities. |
| **Backend API** | Node.js (Express.js) | Handles server-side logic, routing, and user authentication. |
| **Real-time Engine** | Socket.IO | Manages persistent, low-latency connections for instant message transfer. |
| **Database** | MySQL (SQL) | Stores user profiles, chat history, and application metadata. |
| **Security** | JWT & bcryptjs | Implements secure registration, login, and password hashing. |

## 🛠️ Installation and Setup

Follow these three main steps to get the application running on your local machine:

### 1. 💾 Database Setup

1. Ensure your **MySQL/SQL server** is running.
2. Execute the necessary **SQL schema scripts** (e.g., `schema.sql`) found in the `Database/` folder to create the required database and tables.
3. Update the database connection details (host, user, password, database name) in the configuration file (typically a `.env` file) within the `BackendAPI/` folder.

### 2. 💻 Backend Setup (Node.js)

```bash
# 1. Navigate into the backend directory
cd BackendAPI/

# 2. Install all required Node.js packages
npm install

# 3. Start the application server
npm start# 💬 SwiftTalk: Real-time Messaging Application

This is a comprehensive **Full Stack Real-time Chat** application. The project consists of three core parts: a **Mobile Frontend** (Flutter/Android), a **Node.js Backend API**, and a **MySQL Database**.

## 🚀 Key Technologies

| Component | Technology | Role |
| :--- | :--- | :--- |
| **Mobile Frontend** | Flutter / Android Native | User Interface and the client for all messaging functionalities. |
| **Backend API** | Node.js (Express.js) | Handles server-side logic, routing, and user authentication. |
| **Real-time Engine** | Socket.IO | Manages persistent, low-latency connections for instant message transfer. |
| **Database** | MySQL (SQL) | Stores user profiles, chat history, and application metadata. |
| **Security** | JWT & bcryptjs | Implements secure registration, login, and password hashing. |

## 🛠️ Installation and Setup

Follow these three main steps to get the application running on your local machine:

### 1. 💾 Database Setup

1. Ensure your **MySQL/SQL server** is running.
2. Execute the necessary **SQL schema scripts** (e.g., `schema.sql`) found in the `Database/` folder to create the required database and tables.
3. Update the database connection details (host, user, password, database name) in the configuration file (typically a `.env` file) within the `BackendAPI/` folder.

### 2. 💻 Backend Setup (Node.js)

```bash
# 1. Navigate into the backend directory
cd BackendAPI/

# 2. Install all required Node.js packages
npm install

# 3. Start the application server
npm start

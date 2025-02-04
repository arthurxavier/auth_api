# Authentication API with Redis

## Overview
This project is a RESTful authentication API built with **Ruby on Rails**, using **Redis** as the primary data storage instead of a traditional relational database. The API is designed to provide a simple and secure authentication system for internal services, following production-level best practices.

## Problem Statement
The goal of this project is to develop an authentication API that allows user registration and authentication, ensuring security, performance, and error handling. Unlike typical authentication systems that rely on **PostgreSQL** or **MySQL**, this solution uses **Redis** as a key-value store for managing user data.

The API should:
- Allow users to register with a unique username and secure password.
- Authenticate users via a login endpoint.
- Enforce password security policies (length, complexity, special characters).
- Return appropriate HTTP status codes (e.g., 2XX for success, 401 for authentication failures).
- Provide meaningful error messages in JSON format.
- Be fast, secure, and well-tested.

Additionally, the implementation should prioritize simplicity over cleverness, leverage external gems where appropriate, and be capable of passing a basic security audit.

## Technologies
- **Ruby** on Rails (API mode)
- **Redis** (as the primary database)
- **JWT** (JSON Web Token for authentication)
- **BCrypt** (for password hashing)
- **RSpec** (for testing)
- **Docker** & **Docker Compose** (for containerized development)

## Next Steps
1. **Set up the project structure** ✅
2. **Configure Redis as the data store** ✅
3. **Implement a module as an ActiveRecord using RedisRecord** ✅
4. **Implement user registration and authentication** ✅
5. **Add JWT-based authentication** ✅
6. **Write RSpec tests for all API endpoints** ✅
7. **Containerize the application using Docker** ✅
8. **Improve security with password policies and rate limiting** (doing)

## How to Run the Project

### Prerequisites
- **Docker** & **Docker Compose**: Ensure you have Docker and Docker Compose installed on your machine.

### Steps to Run
1. **Clone the repository**:
   ```sh
   git clone https://github.com/yourusername/auth_api.git
   cd auth_api
   ```

2. **Build and run the containers**:
   ```sh
   docker-compose up --build
   ```

3. **Run the setup script**:
   ```sh
   bin/setup
   ```

4. **Start the Rails server**:
   ```sh
   docker-compose run web rails s
   ```

5. **Access the API**:
   The API should now be running at `http://localhost:3000`.

## Future Improvements & Considerations

As the system evolves, several new features and enhancements will be considered for future implementation:

- **Password Confirmation**: Ensure users must confirm their password during registration to prevent errors.
- **Password Expiry**: Introduce password expiration after a certain time period, prompting users to reset their passwords periodically for added security.
- **Password History**: Restrict users from reusing one of their last 5 passwords, enforcing better password hygiene and improving security.
- **I18n Support**: Implement internationalization (I18n) for easier localization of error messages and other outputs.
- **Database Cleanup**: Introduce a more automated way to clean up the database during testing (e.g., using Redis-specific commands to reset state after tests).

These improvements will be made incrementally based on the needs and feedback of the system users and developers.

## Documentation
A detailed explanation of the architecture, decisions, and trade-offs will be included as the implementation progresses. Future improvements and security considerations will also be documented.

---

## Notes and Decisions

### Structure in Redis: Use External ID as Internal Key

While developing the API, I needed to decide how to structure the data in Redis. Since it is a key-value store, the way data is stored directly impacts performance and ease of access.

1. **Which approach makes more sense?**
  - **For many users**: If the number of users is very large (thousands or millions), it makes more sense to store each one as a separate key (`user:1`, `user:2`, etc.). This makes individual searches faster.

  - **For batch operations**: If the system needs to frequently search and modify multiple users at the same time, it may be more efficient to store everything within a single hash (`user:{1: {...}, 2: {...}}`).

2. **Redis Limitations**
   - Redis supports up to 512MB per key, but the critical point in practice is the number of keys managed. Many small keys work well, but a single gigantic key can affect performance.

3. **When can it be problematic?**
  - If there are millions of keys or very large keys, Redis may have memory issues.
  - If the system performs many simultaneous operations on multiple keys, it can increase CPU and network overhead.

### Decision
The main question was to understand if the system would perform more individual searches or batch operations.

In the case of our user login and registration system, the main flows are:
- **Registration**:
  - Needs to validate if the username already exists (global operation).
- **Login**:
  - Searches for the username and validates the password (individual search).

Since the system will have more logins than registrations (especially because users will be logged out after a while), it makes more sense to prioritize individual searches. Therefore, I decided to store each user in a separate key in the format `user:<class>:<id>`.

### Final Structure:
```
user:User:bob_doe -> "{"username": "bob_doe", "password_hash": "$2a$12$3aceHqD3d7b0BnZFRzgbUOR3", "created_at": 1738630522, "updated_at": 1738630522 }"
user:User:alice_smith -> "{"username": "alice_smith", "password_hash": "ZFRzgbUOR3F1wgMu8I19wK", created_at: 1738630652, "updated_at": 1738636722}"
```

#### Advantages:
- Direct access to data with `GET user:User:<id>`.
- Redis optimizes individual searches, making login faster.
- No need to load an entire set of users to get a single piece of data.

#### Disadvantages:
- There may be overhead if there are millions of keys.
- Batch operations on multiple users may be less efficient.

In the end, considering what the system needs to do more frequently, this structure makes more sense.

---

## Author

Developed by **Arthur**, as part of a technical challenge for **Lendesk Technologies ULC**.

---

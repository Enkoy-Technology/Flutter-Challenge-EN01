<img width="900" height="680" alt="image" src="https://github.com/user-attachments/assets/78ff4712-9a69-4395-8993-b1f4fb8eb646" />


# Flutter Real-Time Messaging App Challenge
Your task is to build a real-time chat app with a clean, production-friendly architecture.

## Requirements

### Real-time messaging
- Send and receive messages in real time (Firestore, Supabase Realtime, WebSockets, or similar).
- Each message shows the sender's name, text, and a formatted timestamp.
- Messages appear instantly without manual refresh.

### Chat interface
- Conversation-style UI (chat bubbles).
- Auto-scroll to the newest message when messages arrive or are sent.
- Input field at the bottom to compose and send.

### Bonus (optional)
- Basic user identity (mock login or random user assignment).
- Chat list screen showing conversations.
- Message status (sent/delivered/seen).
- Offline handling and local caching.
- Unit tests for message formatting/time utils or basic logic.

## Engineering expectations
- Clean, feature-based or layered architecture.
- Consistent state management (Riverpod/Bloc/Provider/GetX).
- Repository pattern for data access.
- Reusable widgets and clear naming.
- Error, empty, and loading states.
- Clear separation of UI and business logic.


## How to Submit

<ol>
  <li>
    <p><strong>Fork this repository</strong><br>
    Click the “Fork” button at the top-right of this page.</p>
  </li>

  <li>
    <p><strong>Create a new branch</strong> in your fork named with your full name:</p>
    <pre><code>git checkout -b feature/your-full-name
</code></pre>
  </li>

  <li>
    <p><strong>Build your solution</strong> on that branch, then stage and commit with clear messages:</p>
    <pre><code>git add .
git commit -m "Complete real-time chat challenge"
</code></pre>
  </li>

  <li>
    <p><strong>Push your branch</strong> to your fork:</p>
    <pre><code>git push origin feature/your-full-name
</code></pre>
  </li>

  <li>
    <p><strong>Open a Pull Request</strong> from your fork to this repository’s <code>main</code> branch.</p>
    <p><strong>PR title format:</strong></p>
    <pre><code>Flutter Challenge Submission - Your Full Name
</code></pre>
    <p><strong>PR description must include:</strong></p>
    <ul>
      <li>Steps to run the app (clear setup)</li>
      <li>State management used and why</li>
      <li>Real-time technology used and why (Firestore / Supabase / WebSockets)</li>
      <li>Architecture overview (folders, services, repositories)</li>
      <li>Features completed</li>
      <li>Known limitations or trade-offs</li>
      <li>Improvements you would make with more time</li>
      <li>(Optional) Screenshots or a short demo video</li>
    </ul>
  </li>

  <li>
    <p><strong>Automated review</strong><br>
    CodeRabbit will review your PR automatically. Please write clean, production-quality code.</p>
  </li>
</ol>

### If you cannot fork this repository
- Create your own public GitHub repository
- Push your solution there
- Share the repository link with the same README details

### Optional: keep your fork updated
<pre><code>git remote add upstream https://github.com/&lt;owner&gt;/&lt;repo&gt;.git
git fetch upstream
git checkout feature/your-full-name
git merge upstream/main
</code></pre>



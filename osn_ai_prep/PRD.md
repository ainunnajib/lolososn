# PRD: Aplikasi Web Persiapan OSN AI / NOAI / IOAI

---

## AI Agent Implementation Guide

> **For AI agents (Claude Code, Cursor, etc.) implementing this project**

### Beads Workflow Integration

This is a **long-term, complex project** requiring structured task management. Use **Beads** for tracking features, epics, and tasks across sessions.

#### Initial Setup

After project creation, initialize Beads tracking:

```bash
# Create epic for the entire project
bd create --title="OSN AI Prep Platform" --type=epic --priority=1

# Create feature beads for major components
bd create --title="Core Problem Bank" --type=feature --priority=1
bd create --title="User Authentication" --type=feature --priority=1
bd create --title="MCQ Practice Mode" --type=feature --priority=2
bd create --title="Stripe Subscription" --type=feature --priority=2
bd create --title="Bilingual Support (EN/ID)" --type=feature --priority=2
bd create --title="Leaderboard & Progress" --type=feature --priority=3
bd create --title="Learning Modules" --type=feature --priority=3
bd create --title="Mock Exam System" --type=feature --priority=3
```

#### Task Breakdown Pattern

For each feature, create task beads:

```bash
# Example: Problem Bank feature breakdown
bd create --title="Setup Phoenix project with Postgres" --type=task --priority=1
bd create --title="Create Problem schema & migration" --type=task --priority=1
bd create --title="Implement ProblemLive.Index with filters" --type=task --priority=2
bd create --title="Implement ProblemLive.Show with Colab link" --type=task --priority=2
bd create --title="Seed 30+ problems from IOAI tasks" --type=task --priority=2

# Add dependencies
bd dep add <show-task-id> <index-task-id>
```

#### During Implementation Sessions

```bash
# Start of session: check available work
bd ready

# Claim a task
bd update <task-id> --status=in_progress

# When done with task
bd close <task-id>

# End of session: sync changes
bd sync
```

#### Recommended Beads Structure

```
Epic: OSN AI Prep Platform
├── Feature: Core Problem Bank
│   ├── Task: Setup Phoenix project
│   ├── Task: Problem schema & migration
│   ├── Task: ProblemLive.Index
│   ├── Task: ProblemLive.Show
│   └── Task: Seed problems
├── Feature: User Authentication
│   ├── Task: Run phx.gen.auth
│   ├── Task: Customize auth pages
│   └── Task: Add user profile fields
├── Feature: MCQ Practice Mode
│   ├── Task: MCQ Question schema
│   ├── Task: McqLive.Quiz component
│   ├── Task: Timed exam mode
│   └── Task: Seed 500+ MCQ questions
├── Feature: Stripe Subscription
│   ├── Task: Add subscription fields to User
│   ├── Task: Stripity Stripe setup
│   ├── Task: Pricing page
│   ├── Task: Checkout controller
│   ├── Task: Webhook handler
│   └── Task: Paywall module
├── Feature: Bilingual Support
│   ├── Task: Gettext configuration
│   ├── Task: EN/ID translation files
│   ├── Task: Language toggle component
│   └── Task: Dual-language problem fields
└── ...more features
```

### Ralph Wiggum Plugin Integration

Enable **Ralph Wiggum** to autonomously execute beads tasks:

#### Configuration

Add to project `.ralph/config.yaml`:

```yaml
# Ralph Wiggum configuration for OSN AI Prep
project:
  name: osn-ai-prep
  type: elixir-phoenix

beads:
  enabled: true
  auto_sync: true

execution:
  parallel_tasks: 3
  max_retries: 2

hooks:
  before_task:
    - "bd update {task_id} --status=in_progress"
  after_task:
    - "bd close {task_id}"
    - "bd sync"
  on_error:
    - "bd update {task_id} --status=blocked"

checkpoints:
  - after_each_feature
  - before_deploy
```

#### Running with Ralph Wiggum

```bash
# Execute all ready tasks
ralph run --beads-filter="status=pending"

# Execute specific feature
ralph run --beads-filter="title~=Stripe"

# Execute with priority order
ralph run --beads-priority

# Dry run to see what would be executed
ralph run --dry-run

# Execute and sync beads automatically
ralph run --auto-sync
```

#### Task Execution Flow

```
Ralph Wiggum reads beads → Picks ready tasks (no blockers)
    → Executes task (Claude Code / Cursor)
    → Runs tests
    → If pass: closes bead, syncs
    → If fail: marks blocked, creates fix task
    → Moves to next task
```

#### Best Practices for AI Agents

1. **Always check beads first:**
   ```bash
   bd ready  # What can I work on?
   bd blocked  # What's stuck?
   ```

2. **One task at a time:**
   - Claim task with `bd update --status=in_progress`
   - Complete fully before moving on
   - Close with `bd close` immediately after

3. **Create sub-tasks when needed:**
   - If a task is too complex, break it down
   - Add dependencies between sub-tasks

4. **Sync frequently:**
   ```bash
   bd sync  # After completing work
   ```

5. **Document blockers:**
   ```bash
   bd update <task-id> --status=blocked --reason="Missing API key"
   ```

---

## Executive Summary

Aplikasi web **bilingual (English + Bahasa Indonesia)** untuk mempersiapkan siswa dari **nol menjadi juara AI Olympiad** dalam waktu **2 minggu intensif**.

**Target Audience:**
- 🇮🇩 **Indonesia:** Siswa SMA persiapan OSN AI / Seleksi Pelatnas IOAI
- 🇸🇬 **Singapore:** Students preparing for NOAI (National Olympiad in AI)

Berdasarkan riset mendalam dari silabus IOAI resmi, format kompetisi, dan kesuksesan:
- Tim Indonesia 2025: 3 perak + 1 perunggu (hanya 2 bulan persiapan)
- Tim Singapore 2025: 2 gold + 5 silver di IOAI Beijing

---

## Hasil Riset

### Konteks Kompetisi

**IOAI (International Olympiad in Artificial Intelligence)**
- Kompetisi AI paling prestisius untuk siswa SMA tingkat dunia
- 2025: 284 peserta dari 61 negara, diadakan di Beijing
- Indonesia debut 2025: Peringkat 13 dari 61 negara
- IOAI 2026: UAE | IOAI 2027: Singapore

**Tim Indonesia IOAI 2025:**
- Faiz Rizki Ramadhan - Silver
- Matthew Hutama Pratama - Silver
- Luvidi Pranawa Alghari - Silver
- Jayden Jurianto - Bronze

**Catatan penting:** Tim Indonesia hanya berlatih **2 bulan** dan tetap meraih 4 medali!

---

### NOAI Singapore 2026

**Penyelenggara:** AI Singapore + NTU, didukung MOE & MDDI

**Format Kompetisi:**

| Round | Format | Durasi | Venue |
|-------|--------|--------|-------|
| **Preliminary** | 300 MCQ (online Google Form) | 3 jam | School computer labs |
| **Finals** | 20 MCQ + 3 Programming (Python) | 3 jam | NTU Lab |

**Timeline NOAI 2026:**
- Interest registration: 15 Sep - 28 Nov 2025
- Preliminary Round: TBA
- Finals: TBA
- Top 150 dari Preliminary maju ke Finals

**Eligibility:**
- Full-time students < 20 years old
- MOE-recognized institutions (Secondary, IP, JC, ITE, Polytechnic)
- Any nationality (or home-schooled SG citizens/PR)

**Assessment Areas:**
- Mathematics (Linear Algebra, Calculus, Probability, Optimization)
- Computing (Python, NumPy/Pandas, PyTorch, Debugging)
- AI/ML/DL (Classical ML, Neural Networks, CV, NLP, GenAI)
- Problem Solving (Algorithm Design, System Design)

**Tim Singapore IOAI 2025:** 2 Gold + 5 Silver medals di Beijing!

**Pathway:** NOAI → IOAI 2026 (Abu Dhabi) → IOAI 2027 (Singapore sebagai host!)

---

### Competition Comparison Table

| Aspect | OSN AI (Indonesia) | NOAI Prelim (Singapore) | NOAI Final (Singapore) | IOAI (International) |
|--------|-------------------|-------------------------|------------------------|----------------------|
| **Format** | Essay + Python Coding | 300 MCQ | 20 MCQ + 3 Python | 6 tasks over 2 days |
| **Duration** | ~3-4 hours | 3 hours | 3 hours | ~12 hours total |
| **Venue** | Luring (Jakarta) | School computer labs | NTU Lab | Host country |
| **Difficulty** | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Focus** | Theory + Implementation | Breadth of knowledge | Balanced | Deep problem solving |
| **Tools Allowed** | Laptop, calculator | Google Form (online) | Python environment | Full Python stack |

### Syllabus Depth Comparison

| Topic | OSN AI | NOAI Prelim | NOAI Final | IOAI |
|-------|--------|-------------|------------|------|
| **Python Basics** | Required | MCQ only | Code required | Advanced |
| **NumPy/Pandas** | Basic | Conceptual | Applied | Deep |
| **scikit-learn** | Basic | Conceptual | Applied | Deep |
| **PyTorch** | Optional | Conceptual | Basic | Required |
| **Linear/Logistic Regression** | Theory + Code | MCQ | Both | Both |
| **Decision Trees/RF** | Theory + Code | MCQ | Both | Both |
| **Neural Networks** | Theory + Basic | MCQ | Both | Advanced |
| **CNN** | Concepts | MCQ | Basic | Advanced |
| **Transformers** | Concepts | MCQ | Basic | Required |
| **BERT/GPT** | Awareness | MCQ | Applied | Deep |
| **Transfer Learning** | Optional | MCQ | Basic | Required |
| **Computer Vision** | Basic | Concepts | Applied | Advanced |
| **NLP** | Basic | Concepts | Applied | Advanced |
| **AI Ethics** | Theory | MCQ | MCQ | Essay + Applied |
| **LLM/GenAI** | Awareness | MCQ | Basic | Applied |

### Difficulty Progression

```
NOAI Prelim (Easiest)
    ↓ Breadth focus, MCQ format, conceptual understanding
NOAI Final
    ↓ Balanced, some coding, applied knowledge
OSN AI (Seleksi Pelatnas)
    ↓ Essay + coding, deeper understanding needed
IOAI (Hardest)
    ↓ Complex multi-step problems, novel applications
    ↓ Real research-level challenges
```

### What to Expect at Each Level

**NOAI Preliminary (300 MCQ):**
- "What is the purpose of dropout in neural networks?"
- "Which algorithm is best for clustering?"
- "What does this code output?" (simple snippets)
- Focus: Recognize concepts, recall definitions

**NOAI Final (20 MCQ + 3 Coding):**
- MCQ: More nuanced, "When would you NOT use..."
- Coding: Implement a basic classifier
- Coding: Data preprocessing pipeline
- Focus: Apply knowledge to specific problems

**OSN AI / Seleksi Pelatnas:**
- Essay: "Explain how transformers work and their advantages"
- Coding: Train a model on provided dataset
- Coding: Debug and improve existing code
- Focus: Demonstrate understanding AND implementation

**IOAI:**
- Task: Create adversarial examples for image classifier
- Task: Detect hallucination in LLM outputs
- Task: Multi-modal classification with novel constraints
- Focus: Solve unseen, complex problems creatively

### App Feature: Competition Prep Mode

The app will include a **Competition Selector** to customize the experience:

```
┌─────────────────────────────────────┐
│  What are you preparing for?        │
├─────────────────────────────────────┤
│ ○ NOAI Preliminary (Singapore)      │
│   → Focus on MCQ practice (300 Q)   │
│   → Breadth over depth              │
│                                     │
│ ○ NOAI Final (Singapore)            │
│   → Mixed MCQ + Coding              │
│   → Applied problems                │
│                                     │
│ ○ OSN AI / Pelatnas (Indonesia)     │
│   → Essay + Coding focus            │
│   → Theory + Implementation         │
│                                     │
│ ○ IOAI Preparation                  │
│   → Advanced problems only          │
│   → Past IOAI tasks                 │
└─────────────────────────────────────┘
```

**Based on selection, the app will:**
1. Prioritize relevant content
2. Adjust difficulty curve
3. Show competition-specific tips
4. Recommend study timeline

---

### Seleksi Indonesia 2026

| Tanggal | Kegiatan |
|---------|----------|
| 30 Des 2025 | Pembukaan pendaftaran |
| 15 Jan 2026 | Sosialisasi daring |
| 18 Jan 2026 | Penutupan pendaftaran |
| 24 Jan 2026 | Pelaksanaan seleksi (luring, Jakarta) |

**Kriteria:**
- Siswa SMA/MA/SMK aktif (kelas 9-12)
- Lolos final OSN 2025 (Informatika atau Matematika)
- Persetujuan orangtua dan guru

**Format Ujian:**
- Soal esai/teori
- Pemrograman Python (submit program)

### Silabus IOAI 2026 (4 Bagian Utama)

#### 1. Foundational Skills & Classical ML
| Topik | Level |
|-------|-------|
| Python, NumPy, Pandas, Matplotlib | Practice |
| Scikit-learn, PyTorch | Practice |
| Tensor operations | Practice |
| Regresi Linear & Logistik | Both |
| K-NN, Decision Trees | Both |
| Random Forests, Gradient Boosting | Both |
| SVM | Both |
| K-Means, PCA, t-SNE, DBSCAN | Both |
| Cross-validation, ROC curves | Both |
| Underfitting/Overfitting | Theory |
| Hyperparameter tuning | Practice |

#### 2. Neural Networks & Deep Learning
| Topik | Level |
|-------|-------|
| Perceptron, MLP | Both |
| Gradient descent, Backpropagation | Theory |
| Activation functions | Both |
| Momentum, Adam optimizer | Both |
| Regularization (L1, L2, Dropout) | Both |
| Early stopping, Batch normalization | Practice |
| Autoencoders | Both |

#### 3. Computer Vision
| Topik | Level |
|-------|-------|
| Convolution, Pooling | Theory |
| CNN architecture | Both |
| Image classification | Practice |
| Object detection, Segmentation | Practice |
| Transfer learning | Practice |
| Data augmentation | Practice |
| GAN basics | Theory |
| Vision Transformers (ViT) | Both |
| CLIP | Both |

#### 4. Natural Language Processing
| Topik | Level |
|-------|-------|
| Word embeddings (Word2Vec, GloVe) | Theory |
| Transformer architecture | Theory |
| Attention mechanism | Both |
| Text classification | Practice |
| Pre-trained models (BERT, GPT) | Both |
| Question answering | Practice |
| LLM basics | Both |
| Fine-tuning | Practice |
| LLM agents | Theory |

### Contoh Soal IOAI 2025

1. **Radar** - Pattern recognition dari sinyal radar
2. **Chicken Counting** - Object counting dalam gambar
3. **Concepts** - NLP classification
4. **Restroom Icon Matching** - Image matching
5. **Antique Painting Authentication** - ML authentication
6. **Pixel Parsimony** - Optimization task

### Format Kompetisi IOAI

- **Individual Contest:** 2 hari, ~6 jam/hari, 2-3 task
- **At-home Tasks:** Diberikan 1 bulan sebelum kompetisi
- **Team Challenge:** Robotics "Future Factory"
- **GAITE Contest:** Versi simplified dengan hints

**Distribusi Medali:** ~50% peserta dapat medali (rasio 1:2:3 untuk gold:silver:bronze)

---

## Spesifikasi Aplikasi

### Target Users

**🇮🇩 Indonesian Students:**
- Siswa SMA/MA/SMK (kelas 9-12)
- Lolos OSN Informatika/Matematika 2025
- Raw talent tinggi / high IQ
- Waktu persiapan: 2 minggu intensif (8-10 jam/hari)

**🇸🇬 Singaporean Students:**
- Secondary, IP, JC, ITE, Polytechnic students (< 20 years)
- Any nationality studying in MOE-recognized institutions
- Preparing for NOAI Preliminary (300 MCQ) and Finals
- Can also be home-schooled SG citizens/PR

### Core Features

#### 0. Competition Prep Mode Selector (Onboarding)

**First-time user experience:**

User selects their target competition on signup:

| Mode | Target | Focus |
|------|--------|-------|
| 🇸🇬 NOAI Prelim | 300 MCQ mastery | Breadth, recall, concepts |
| 🇸🇬 NOAI Final | MCQ + Coding | Applied knowledge |
| 🇮🇩 OSN AI | Essay + Coding | Theory + Implementation |
| 🌏 IOAI | Advanced problems | Deep problem solving |

**Mode affects:**
- Content ordering (MCQ-first vs coding-first)
- Difficulty progression
- Recommended timeline
- Dashboard metrics
- Practice emphasis

**Users can switch modes anytime from settings.**

#### 1. Adaptive Learning Path (Dashboard Utama)

**Day-by-Day Curriculum (14 Days)**

| Hari | Focus | Durasi |
|------|-------|--------|
| 1-2 | Python Mastery (NumPy, Pandas, Matplotlib) | 16 jam |
| 3-4 | ML Fundamentals (scikit-learn) | 16 jam |
| 5-6 | Neural Networks & PyTorch | 16 jam |
| 7-8 | Computer Vision (CNN, Transfer Learning) | 16 jam |
| 9-10 | NLP & Transformers | 16 jam |
| 11-12 | Advanced Topics (BERT, CLIP, LLM) | 16 jam |
| 13 | Practice Problems (Past IOAI Tasks) | 8 jam |
| 14 | Mock Exam & Review | 8 jam |

**Progress Tracking:**
- Visual progress bar per modul
- Skill radar chart (ML, CV, NLP, Theory)
- Daily goals & streaks

#### 2. Interactive Lessons (Materi Pembelajaran)

Untuk setiap topik:
- **Concept Card:** Penjelasan singkat (maks 500 kata)
- **Visual Explanation:** Animasi/diagram interaktif (inspirasi 3Blue1Brown)
- **Code Playground:** Jupyter-like editor dengan auto-grading
- **Quick Quiz:** 5-10 soal untuk validasi pemahaman

**Konten per Section:**

**Section 1: Python & ML Basics**
- NumPy arrays & vectorization
- Pandas DataFrames
- Matplotlib visualization
- scikit-learn pipeline
- Train/test split, cross-validation
- Evaluation metrics (accuracy, precision, recall, F1, ROC-AUC)

**Section 2: Classical ML**
- Linear & Logistic Regression
- Decision Trees & Random Forests
- Gradient Boosting (XGBoost)
- K-Means & PCA
- SVM basics

**Section 3: Deep Learning**
- Perceptron & MLP
- Backpropagation (visual explanation)
- Activation functions
- Optimizers (SGD, Adam)
- Regularization techniques
- PyTorch fundamentals

**Section 4: Computer Vision**
- Convolution operations
- CNN architecture (LeNet, VGG, ResNet)
- Transfer learning dengan pretrained models
- Image augmentation
- Object detection concepts
- Vision Transformers & CLIP

**Section 5: NLP**
- Word embeddings
- Transformer architecture
- Attention mechanism
- BERT & text classification
- GPT & language modeling
- Fine-tuning pretrained models
- LLM basics & prompting

**Section 6: AI Ethics**
- Bias & fairness
- Hallucination in LLMs
- Privacy concerns
- Responsible AI

#### 3. Problem Bank (Latihan Soal)

**Kategori Soal:**
- **Esai/Teori:** Multiple choice + short answer
- **Coding:** Submit Python code dengan test cases

**Sumber Soal:**
- Past IOAI tasks (2024, 2025)
- National selections (Poland, Romania, China, USA)
- Custom problems berdasarkan silabus
- Kaggle-style mini competitions

**Fitur:**
- Difficulty rating (Easy/Medium/Hard)
- Tags per topik (CNN, NLP, etc.)
- Solution & explanation
- Leaderboard

#### 4. Code Sandbox (IDE Online)

- Jupyter Notebook environment
- Pre-installed: NumPy, Pandas, scikit-learn, PyTorch, transformers
- GPU access untuk deep learning tasks
- Auto-save & version history
- Template notebooks per topik

#### 5. Mock Exams

- Simulasi ujian dengan time pressure
- Format mirip seleksi IOAI:
  - 2-3 soal dalam 4-6 jam
  - Kombinasi teori + coding
- Instant feedback & scoring
- Detailed solution walkthrough

#### 6. MCQ Practice Mode (NOAI Preliminary Focus) 🇸🇬

**For Singapore students preparing for NOAI Preliminary (300 MCQ):**

- **Question Bank:** 500+ MCQ questions across all topics
- **Timed Practice:** Simulate 3-hour exam (300 questions)
- **Topic Quizzes:** Focus on weak areas
  - Mathematics (Linear Algebra, Calculus, Probability)
  - Computing (Python, Data Structures)
  - AI/ML Concepts (Supervised/Unsupervised, Neural Networks)
  - NLP & CV Theory
- **Instant Feedback:** Explanation for each answer
- **Progress Tracking:** Accuracy per topic
- **Difficulty Levels:** Easy → Medium → Hard progression

**MCQ Types:**
- Conceptual understanding
- Code output prediction
- Algorithm analysis
- Mathematical calculations
- Best practice identification

#### 7. Resource Library

**Curated External Resources (Language-specific):**

| Resource | EN | ID |
|----------|----|----|
| Kaggle Learn (Python, ML) | ✓ | ✓ |
| fast.ai Practical Deep Learning | ✓ | - |
| 3Blue1Brown Neural Networks | ✓ | ✓ |
| Andrew Ng ML/DL Specialization | ✓ | ✓ |
| PyTorch tutorials | ✓ | ✓ |
| IOAI official materials | ✓ | ✓ |
| AI Singapore LearnAI | ✓ | - |

**Cheat Sheets:**
- NumPy/Pandas quick reference
- scikit-learn API summary
- PyTorch common patterns
- Model comparison table

#### 8. Community Features

- Discussion forum per topik
- Study groups (ID/EN separate)
- Mentor Q&A (optional)
- Progress sharing

---

## Monetization: Freemium + Subscription

### Pricing Tiers

| Feature | Free | Premium |
|---------|------|---------|
| **Lessons** | 3 intro lessons per section | All lessons |
| **Problems** | 5 starter problems | 50+ problems |
| **MCQ Practice** | 30 sample questions | 500+ questions |
| **Mock Exams** | 1 mini mock (30 min) | Full mock exams (3+ hours) |
| **Leaderboard** | View only | Participate & rank |
| **Colab Notebooks** | Basic templates | All problem notebooks |
| **Progress Tracking** | Basic stats | Detailed analytics |
| **AI Hints** | ❌ | ✓ Unlimited |
| **Certificate** | ❌ | ✓ Completion certificate |

### Subscription Plans

| Plan | Price | Best For |
|------|-------|----------|
| **Free** | $0 | Try before you buy |
| **Monthly** | $9.99/mo | Short-term prep |
| **Yearly** | $79/year (~$6.60/mo) | Best value |
| **Lifetime** | $149 one-time | Serious competitors |

**Regional Pricing:**
- 🇮🇩 Indonesia: IDR 99K/mo atau IDR 799K/year
- 🇸🇬 Singapore: SGD 12/mo atau SGD 99/year

### Stripe Integration

**Library:** [Stripity Stripe](https://hexdocs.pm/stripity_stripe/) atau [Bling](https://github.com/gkpacker/bling)

**Key Components:**

1. **Stripe Checkout** - Hosted payment page (simplest)
2. **Customer Portal** - Manage subscriptions
3. **Webhooks** - Sync subscription status

**Implementation Flow:**
```
User clicks "Upgrade"
    → Redirect to Stripe Checkout
    → Payment processed
    → Webhook received (checkout.session.completed)
    → Update user.subscription_status in DB
    → Unlock premium content
```

**Database Schema Addition:**
```elixir
schema "users" do
  # ... existing fields
  field :stripe_customer_id, :string
  field :subscription_status, :string, default: "free"  # free, active, canceled, past_due
  field :subscription_plan, :string  # monthly, yearly, lifetime
  field :subscription_ends_at, :utc_datetime

  # Competition prep mode
  field :prep_mode, :string, default: "noai_prelim"  # noai_prelim, noai_final, osn_ai, ioai
  field :preferred_language, :string, default: "en"  # en, id

  timestamps()
end
```

**Prep Mode Enum:**
```elixir
# lib/osn_ai_prep/accounts/prep_mode.ex
defmodule OsnAiPrep.Accounts.PrepMode do
  @modes %{
    "noai_prelim" => %{
      name: "NOAI Preliminary",
      country: "SG",
      focus: :mcq,
      difficulty: 2,
      duration_days: 14
    },
    "noai_final" => %{
      name: "NOAI Final",
      country: "SG",
      focus: :mixed,
      difficulty: 3,
      duration_days: 14
    },
    "osn_ai" => %{
      name: "OSN AI / Pelatnas",
      country: "ID",
      focus: :coding,
      difficulty: 3,
      duration_days: 14
    },
    "ioai" => %{
      name: "IOAI Preparation",
      country: "International",
      focus: :advanced,
      difficulty: 5,
      duration_days: 30
    }
  }

  def get(mode), do: @modes[mode]
  def all, do: @modes
end
```

**Paywall Logic:**
```elixir
# lib/osn_ai_prep/subscriptions/paywall.ex
defmodule OsnAiPrep.Subscriptions.Paywall do
  @free_lessons [1, 2, 3]
  @free_problems [1, 2, 3, 4, 5]
  @free_mcq_limit 30

  def can_access_lesson?(user, lesson_id) do
    user.subscription_status == "active" or lesson_id in @free_lessons
  end

  def can_access_problem?(user, problem_id) do
    user.subscription_status == "active" or problem_id in @free_problems
  end

  def mcq_remaining(user) do
    if user.subscription_status == "active" do
      :unlimited
    else
      max(0, @free_mcq_limit - user.mcq_attempts_count)
    end
  end
end
```

**Webhook Handler:**
```elixir
# lib/osn_ai_prep_web/controllers/webhook_controller.ex
defmodule OsnAiPrepWeb.WebhookController do
  use OsnAiPrepWeb, :controller

  def stripe(conn, %{"type" => "checkout.session.completed"} = event) do
    customer_id = event["data"]["object"]["customer"]
    Subscriptions.activate_subscription(customer_id)
    send_resp(conn, 200, "OK")
  end

  def stripe(conn, %{"type" => "customer.subscription.deleted"} = event) do
    customer_id = event["data"]["object"]["customer"]
    Subscriptions.cancel_subscription(customer_id)
    send_resp(conn, 200, "OK")
  end
end
```

### Paywall UX Best Practices

1. **Value First:** Show free content quality before asking to upgrade
2. **Soft Paywall:** Allow dismissing, show upgrade benefits
3. **Progress Motivation:** "Unlock 45 more problems to continue your journey"
4. **Social Proof:** "Join 500+ students preparing for IOAI"
5. **Urgency (optional):** "Early bird: 30% off ends in 7 days"

### Conversion Optimization

- Free trial: 7 days full access (no card required)
- Exit intent popup with discount offer
- Email sequences for trial → paid conversion
- Track: paywall encounter rate, bounce rate, time-to-conversion

---

## Technical Architecture

### Tech Stack: Elixir/Phoenix

**Framework:**
- **Elixir** - Functional language on BEAM VM
- **Phoenix 1.8** - Web framework
- **Phoenix LiveView 1.1** - Real-time interactive UI (no JavaScript needed!)
- **Tailwind CSS** - Built-in dengan Phoenix

**Database:**
- **PostgreSQL** - Default untuk Phoenix
- **Ecto** - Database wrapper & query generator

**Code Execution:**
- Google Colab integration (external notebooks)
- Pre-made Colab templates per problem type
- "Open in Colab" buttons dengan pre-loaded test data

**AI Features:**
- OpenAI API via Req library (hint generation)
- Elixir NX ecosystem jika perlu ML on-server

---

### Deployment Recommendations

| Platform | Best For | Pricing | Notes |
|----------|----------|---------|-------|
| **Fly.io** (Recommended) | Global distribution, clustering | ~$5-10/mo starter | Built-in BEAM support, easy clustering |
| **Gigalixir** | Full BEAM features | $5/0.1GB/mo | Hot upgrades, observer, best for Elixir |
| **Render** | Simple deployments | $7/0.5GB/mo | Limited SSH access |

**Rekomendasi:**
- **Development & MVP:** Fly.io (free tier available, easy setup)
- **Production:** Gigalixir (full BEAM features untuk scaling)

### Database Hosting

| Provider | Best For | Pricing |
|----------|----------|---------|
| **Fly Postgres** | Bundled dengan Fly.io | Included in Fly |
| **Supabase** | Realtime, auth built-in | Free tier generous |
| **Neon** | Serverless Postgres | Free tier 0.5GB |
| **Gigalixir DB** | Bundled dengan Gigalixir | $10/mo 0.6GB |

**Rekomendasi:**
- **Fly.io deploy:** Fly Postgres (integrated)
- **Gigalixir deploy:** Gigalixir managed DB

---

### Why Elixir/Phoenix for This Project?

1. **LiveView = Less Code**
   - Real-time updates tanpa JavaScript
   - Single codebase (server-side only)
   - "Feels like cheating" - Jose Valim

2. **Scalability**
   - Handle 25,000+ concurrent connections per GB RAM
   - Clustering built-in
   - WhatsApp & Discord use BEAM

3. **Developer Productivity**
   - 1 Elixir dev = 3-5 engineers dengan stack lain
   - Full-stack dalam satu language
   - Pattern matching makes code readable

4. **Perfect for Learning Platform**
   - Real-time leaderboard updates
   - Live progress tracking
   - WebSocket-based collaboration (future)

---

### Bilingual Implementation (English + Bahasa Indonesia)

**Approach:** Gettext-based i18n (built-in dengan Phoenix)

**Key Features:**
- Language toggle di navbar
- Auto-detect dari browser preference
- Remember user preference di session/cookie
- URL prefix optional: `/en/problems` vs `/id/problems`

**Gettext Setup:**
```elixir
# lib/osn_ai_prep_web/gettext.ex
defmodule OsnAiPrepWeb.Gettext do
  use Gettext.Backend, otp_app: :osn_ai_prep
end

# Usage in templates:
~H"""
<h1><%= gettext("Problem Bank") %></h1>
<p><%= gettext("Solve problems to improve your AI skills") %></p>
"""
```

**Translation Files:**
```
priv/gettext/
├── en/LC_MESSAGES/
│   └── default.po          # English translations
└── id/LC_MESSAGES/
    └── default.po          # Bahasa Indonesia translations
```

**Content Strategy:**
| Content Type | Approach |
|--------------|----------|
| UI Text | Gettext translations |
| Problem descriptions | Dual-language fields in DB |
| Learning materials | Separate MDX files per language |
| External resources | Language-specific curated links |

**Database Schema for Bilingual Content:**
```elixir
schema "problems" do
  field :title_en, :string
  field :title_id, :string
  field :description_en, :text
  field :description_id, :text
  field :difficulty, :string
  field :topic, :string
  field :colab_url, :string
  timestamps()
end
```

**Competition-Specific Content:**

| Audience | Focus |
|----------|-------|
| 🇸🇬 Singapore (EN) | NOAI Prelim (300 MCQ practice), Finals prep |
| 🇮🇩 Indonesia (ID) | OSN AI/Seleksi Pelatnas, Essay + Coding |

**MCQ Practice Mode (for NOAI Prelim):**
- Dedicated MCQ section dengan 300+ practice questions
- Timed practice mode (3 hours)
- Topic-wise MCQ quizzes
- Instant feedback dengan explanations

### Database Schema (Core)

```
User
  - id, email, name
  - currentDay, totalProgress
  - skillScores (ML, CV, NLP, Theory)

Lesson
  - id, sectionId, title, content
  - difficulty, estimatedMinutes
  - order

LessonProgress
  - userId, lessonId
  - completed, score, timeSpent

Problem
  - id, type (essay/coding)
  - title, description, testCases
  - difficulty, tags
  - solution

Submission
  - userId, problemId
  - code, result, score
  - submittedAt

MockExam
  - id, title, duration
  - problems[]

ExamAttempt
  - userId, examId
  - startedAt, completedAt
  - totalScore
```

---

## Implementation Plan

### Keputusan Arsitektur
- **Project:** Proyek baru terpisah (bukan bagian dari Mahakam Dashboard)
- **Code Execution:** External via Google Colab (link ke notebooks)
- **MVP Focus:** Problem Bank + Coding

### Phase 1: MVP - Problem Bank Focus (3-5 hari)

**Day 1: Project Setup**
```bash
# Install Elixir & Phoenix
mix archive.install hex phx_new

# Create project
mix phx.new osn_ai_prep --database postgres

# Setup database
cd osn_ai_prep
mix ecto.create

# Start server
mix phx.server  # http://localhost:4000
```

1. Generate Phoenix project dengan PostgreSQL
2. Setup database migrations:
   - Users table (email, password_hash, name)
   - Problems table (title, description, difficulty, topic, colab_url)
   - Submissions table (user_id, problem_id, solved_at)
3. Configure Tailwind (sudah built-in)
4. Setup auth dengan `mix phx.gen.auth`

**Day 2: Core Problem Bank (LiveView)**
1. Generate contexts:
   ```bash
   mix phx.gen.context Problems Problem problems \
     title:string description:text difficulty:string \
     topic:string colab_url:string
   ```
2. Create LiveView pages:
   - `ProblemLive.Index` - Problem list dengan filters
   - `ProblemLive.Show` - Problem detail + Colab link
3. Implement filtering by topic & difficulty

**Day 3: Auth & Submissions**
1. Setup user authentication:
   ```bash
   mix phx.gen.auth Accounts User users
   ```
2. Create submission tracking:
   - Mark problem as solved
   - Track solve timestamp
   - Update user stats

**Day 4: Dashboard & Leaderboard (Real-time!)**
1. `DashboardLive`:
   - Problems solved counter
   - Topic-wise progress bars
   - Recent activity
2. `LeaderboardLive` dengan PubSub:
   - Real-time ranking updates
   - Top 100 users
   - User's current rank

**Day 5: Content & Deploy**
1. Seed 30+ problems via `priv/repo/seeds.exs`
2. Create Colab notebook templates
3. Deploy to Fly.io:
   ```bash
   fly launch
   fly deploy
   ```

### Phase 2: Stripe & Paywall (3-4 days)

**Setup Stripe:**
1. Create Stripe account & get API keys
2. Configure products & prices in Stripe Dashboard:
   - Monthly: $9.99/mo
   - Yearly: $79/year
   - Lifetime: $149 one-time
3. Add Stripity Stripe to deps
4. Configure webhooks endpoint

**Implement Paywall:**
1. Add subscription fields to User schema
2. Create Subscriptions context with paywall logic
3. Pricing page with plan comparison
4. Checkout flow (redirect to Stripe)
5. Webhook handler for subscription events
6. Apply paywall to protected content

### Phase 3: Learning Modules (Week 2)
1. Add materi pembelajaran per section
2. Quick quiz per topik
3. Resource library dengan curated links
4. Study path recommendations
5. Free vs premium content gating

### Phase 4: MCQ & Mock Exam (Week 2-3)
1. MCQ question bank (500+ questions)
2. MCQ practice mode dengan timer
3. Mock exam dengan timer (3 hours)
4. AI-powered hints (OpenAI) - premium only

### Phase 5: Polish & Launch (Week 3)
1. Community discussion
2. Mobile optimization
3. Email sequences for conversion
4. Analytics & tracking setup

---

## File Structure (Phoenix/Elixir)

```
osn_ai_prep/
├── lib/
│   ├── osn_ai_prep/                    # Business logic (contexts)
│   │   ├── accounts/                   # User accounts context
│   │   │   ├── user.ex                 # User schema
│   │   │   └── accounts.ex             # Account functions
│   │   ├── problems/                   # Problems context
│   │   │   ├── problem.ex              # Problem schema
│   │   │   ├── submission.ex           # Submission schema
│   │   │   └── problems.ex             # Problem functions
│   │   ├── subscriptions/              # Stripe & paywall context
│   │   │   ├── subscription.ex         # Subscription schema
│   │   │   ├── paywall.ex              # Access control logic
│   │   │   └── subscriptions.ex        # Stripe integration
│   │   ├── leaderboard/                # Leaderboard context
│   │   │   └── leaderboard.ex          # Ranking functions
│   │   ├── repo.ex                     # Ecto Repo
│   │   └── application.ex              # App supervisor
│   │
│   └── osn_ai_prep_web/                # Web layer
│       ├── components/                 # Reusable UI components
│       │   ├── core_components.ex      # Built-in Phoenix components
│       │   ├── layouts.ex              # App layouts
│       │   ├── problem_components.ex   # Problem-specific components
│       │   └── dashboard_components.ex # Dashboard components
│       │
│       ├── live/                       # LiveView modules
│       │   ├── home_live.ex            # Landing page
│       │   ├── problem_live/
│       │   │   ├── index.ex            # Problem list + filters
│       │   │   └── show.ex             # Problem detail + Colab
│       │   ├── mcq_live/               # MCQ Practice (NOAI focus)
│       │   │   ├── index.ex            # MCQ topic selection
│       │   │   ├── quiz.ex             # Quiz session
│       │   │   └── timed_exam.ex       # Full 300 MCQ simulation
│       │   ├── dashboard_live.ex       # User dashboard
│       │   ├── leaderboard_live.ex     # Rankings (real-time!)
│       │   └── auth_live/
│       │       ├── login.ex
│       │       └── register.ex
│       │
│       ├── live/                       # Additional LiveViews
│       │   └── pricing_live.ex         # Pricing page with plans
│       │
│       ├── controllers/                # Traditional controllers
│       │   ├── session_controller.ex   # Auth sessions
│       │   ├── page_controller.ex      # Static pages
│       │   ├── checkout_controller.ex  # Stripe checkout redirect
│       │   └── webhook_controller.ex   # Stripe webhooks
│       │
│       ├── router.ex                   # Routes definition
│       ├── endpoint.ex                 # HTTP endpoint
│       └── telemetry.ex                # Metrics
│
├── priv/
│   ├── repo/migrations/                # Database migrations
│   ├── static/                         # Static assets
│   │   └── colab-notebooks/            # Reference notebooks
│   ├── gettext/                        # i18n translations
│   │   ├── en/LC_MESSAGES/default.po   # English
│   │   └── id/LC_MESSAGES/default.po   # Bahasa Indonesia
│   └── seeds/                          # Seed data
│       ├── problems.exs                # Problem seed data
│       └── mcq_questions.exs           # MCQ seed data (500+ questions)
│
├── config/
│   ├── config.exs                      # Base config
│   ├── dev.exs                         # Dev environment
│   ├── prod.exs                        # Production
│   ├── runtime.exs                     # Runtime config (secrets)
│   └── test.exs                        # Test environment
│
├── test/                               # Tests
│   ├── osn_ai_prep/                    # Context tests
│   └── osn_ai_prep_web/                # LiveView tests
│
├── assets/                             # Frontend assets
│   ├── css/app.css                     # Tailwind entry
│   ├── js/app.js                       # JS hooks (minimal)
│   └── tailwind.config.js
│
├── mix.exs                             # Dependencies
├── fly.toml                            # Fly.io config (optional)
└── Dockerfile                          # For deployment
```

### Key Dependencies (mix.exs)

```elixir
defp deps do
  [
    # Phoenix core
    {:phoenix, "~> 1.8.0"},
    {:phoenix_html, "~> 4.2"},
    {:phoenix_live_view, "~> 1.1"},
    {:phoenix_live_dashboard, "~> 0.8"},

    # Database
    {:phoenix_ecto, "~> 4.6"},
    {:ecto_sql, "~> 3.12"},
    {:postgrex, ">= 0.0.0"},

    # Auth
    {:bcrypt_elixir, "~> 3.0"},

    # Assets
    {:tailwind, "~> 0.2"},
    {:esbuild, "~> 0.8"},
    {:heroicons, "~> 0.5"},

    # HTTP client (for OpenAI hints)
    {:req, "~> 0.5"},

    # Stripe payments
    {:stripity_stripe, "~> 3.0"},

    # Markdown parsing (for problem descriptions)
    {:earmark, "~> 1.4"},

    # Telemetry
    {:telemetry_metrics, "~> 1.0"},
    {:telemetry_poller, "~> 1.0"},

    # Dev/Test
    {:floki, ">= 0.0.0", only: :test},
    {:phoenix_live_reload, "~> 1.2", only: :dev}
  ]
end
```

### Key Elixir Conventions

**Contexts** - Group related functionality:
```elixir
# lib/osn_ai_prep/problems/problems.ex
defmodule OsnAiPrep.Problems do
  def list_problems(filters \\ %{}) do
    # Query problems with filters
  end

  def get_problem!(id), do: Repo.get!(Problem, id)

  def mark_solved(user, problem) do
    # Create submission, update stats
  end
end
```

**LiveView** - Real-time UI:
```elixir
# lib/osn_ai_prep_web/live/leaderboard_live.ex
defmodule OsnAiPrepWeb.LeaderboardLive do
  use OsnAiPrepWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to real-time updates
      Phoenix.PubSub.subscribe(OsnAiPrep.PubSub, "leaderboard")
    end
    {:ok, assign(socket, rankings: Leaderboard.get_rankings())}
  end

  def handle_info({:ranking_updated, rankings}, socket) do
    {:noreply, assign(socket, rankings: rankings)}
  end
end
```

---

## Verification Plan

### MVP Testing Checklist
1. [ ] User dapat register dan login via Phoenix Auth
2. [ ] Problem list page menampilkan semua problems dengan filter
3. [ ] Problem detail page menampilkan deskripsi lengkap
4. [ ] "Open in Colab" button berfungsi dan membuka notebook yang benar
5. [ ] User dapat mark problem sebagai "solved"
6. [ ] Dashboard menampilkan progress statistics
7. [ ] Leaderboard real-time update saat ada user solve problem
8. [ ] Mobile responsive
9. [ ] Performance: < 100ms LiveView updates
10. [ ] Language toggle berfungsi (EN ↔ ID)

### Subscription Testing Checklist
1. [ ] Free tier: hanya bisa akses 3 lessons, 5 problems, 30 MCQ
2. [ ] Pricing page menampilkan semua plans dengan benar
3. [ ] Checkout redirect ke Stripe berfungsi
4. [ ] Stripe test payment berhasil (test card: 4242...)
5. [ ] Webhook update subscription status di database
6. [ ] Premium user dapat akses semua konten
7. [ ] Subscription cancel flow berfungsi
8. [ ] Paywall popup muncul saat free user access premium content

### Content Quality
1. [ ] Minimal 30 problems tersedia (10 ML, 10 CV, 10 NLP)
2. [ ] Setiap problem memiliki Colab notebook yang berfungsi
3. [ ] Difficulty tags akurat (Easy/Medium/Hard)
4. [ ] Topics sesuai silabus IOAI 2026

### How to Test (Development)
```bash
# 1. Setup & start dev server
cd osn_ai_prep
mix setup           # Install deps + create DB + run migrations
mix phx.server      # Start server

# 2. Open browser
open http://localhost:4000

# 3. Test user flow
- Register new account
- Browse problems (/problems)
- Open a problem in Colab
- Mark as solved
- Check dashboard (/dashboard)
- View leaderboard (/leaderboard)

# 4. Run tests
mix test
```

### How to Test (Production - Fly.io)
```bash
# Deploy
fly launch           # First time setup
fly deploy           # Deploy updates
fly status           # Check status
fly logs             # View logs

# Database
fly postgres connect # Connect to DB
fly ssh console      # SSH into app
```

---

## Key Success Metrics

1. **Learning Effectiveness:** User dapat complete 14-day program
2. **Engagement:** Daily active users, lesson completion rate
3. **Problem Solving:** Average score improvement over time
4. **Mock Exam Performance:** Score distribution

---

## Sources

### IOAI & Competition Resources
- [IOAI Official](https://ioai-official.org/)
- [IOAI 2025 Syllabus](https://ioai-official.org/china-2025/syllabus-2025/)
- [IOAI Tasks Collection](https://github.com/open-cu/awesome-ioai-tasks)
- [IOAI 2025 Dataset](https://huggingface.co/datasets/IOAI-official/IOAI2025)

### Indonesia
- [IOAI Indonesia (TOKI)](https://ioai.toki.id/)
- [Seleksi 2026](https://ioai.toki.id/seleksi2026.html)

### Singapore
- [AI Singapore - NOAI](https://aisingapore.org/talent/national-olympiad-in-artificial-intelligence/)
- [LearnAI - NOAI Resources](https://learn.aisingapore.org/national-olympiad-in-artificial-intelligence/)

### Learning Resources
- [Kaggle Learn](https://www.kaggle.com/learn)
- [fast.ai](https://course.fast.ai/)
- [3Blue1Brown Neural Networks](https://www.3blue1brown.com/topics/neural-networks)
- [Andrew Ng ML Specialization](https://www.coursera.org/specializations/machine-learning-introduction)

### Elixir/Phoenix
- [Phoenix Framework](https://www.phoenixframework.org/)
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view)
- [Fly.io Elixir Deployment](https://fly.io/docs/elixir/)
- [Gigalixir](https://www.gigalixir.com/)

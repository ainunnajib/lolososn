# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     OsnAiPrep.Repo.insert!(%OsnAiPrep.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias OsnAiPrep.Repo
alias OsnAiPrep.Problems.Problem
alias OsnAiPrep.Mcq.Question

# Clear existing data
Repo.delete_all(Question)
Repo.delete_all(Problem)

# Seed Problems based on IOAI 2025 tasks and similar competitions
problems = [
  # IOAI 2025 Tasks
  %{
    title_en: "Radar Signal Classification",
    title_id: "Klasifikasi Sinyal Radar",
    description_en: "Analyze radar signals to detect and classify different types of objects. You'll work with raw signal data and implement machine learning models for pattern recognition in time-series data.",
    description_id: "Analisis sinyal radar untuk mendeteksi dan mengklasifikasikan berbagai jenis objek. Anda akan bekerja dengan data sinyal mentah dan mengimplementasikan model machine learning untuk pengenalan pola dalam data time-series.",
    difficulty: "hard",
    topic: "neural_networks",
    colab_url: "https://colab.research.google.com/drive/1example1",
    competition: "ioai"
  },
  %{
    title_en: "Chicken Counting in Images",
    title_id: "Menghitung Ayam dalam Gambar",
    description_en: "Implement an object detection and counting system for poultry monitoring. Given images of chicken farms, accurately count the number of chickens using computer vision techniques.",
    description_id: "Implementasikan sistem deteksi dan penghitungan objek untuk pemantauan unggas. Diberikan gambar peternakan ayam, hitung jumlah ayam secara akurat menggunakan teknik computer vision.",
    difficulty: "medium",
    topic: "computer_vision",
    colab_url: "https://colab.research.google.com/drive/1example2",
    competition: "ioai"
  },
  %{
    title_en: "Text Concept Classification",
    title_id: "Klasifikasi Konsep Teks",
    description_en: "Build an NLP classifier to categorize text documents into predefined concept categories. Use transformer-based models for text understanding and classification.",
    description_id: "Bangun classifier NLP untuk mengkategorikan dokumen teks ke dalam kategori konsep yang telah ditentukan. Gunakan model berbasis transformer untuk pemahaman dan klasifikasi teks.",
    difficulty: "hard",
    topic: "nlp",
    colab_url: "https://colab.research.google.com/drive/1example3",
    competition: "ioai"
  },
  %{
    title_en: "Restroom Icon Matching",
    title_id: "Pencocokan Ikon Toilet",
    description_en: "Create an image matching system that can correctly identify and match restroom icons across different styles and designs using computer vision.",
    description_id: "Buat sistem pencocokan gambar yang dapat mengidentifikasi dan mencocokkan ikon toilet di berbagai gaya dan desain menggunakan computer vision.",
    difficulty: "medium",
    topic: "computer_vision",
    colab_url: "https://colab.research.google.com/drive/1example4",
    competition: "ioai"
  },
  %{
    title_en: "Antique Painting Authentication",
    title_id: "Otentikasi Lukisan Antik",
    description_en: "Develop a machine learning system to authenticate antique paintings by analyzing artistic style, brushwork patterns, and material characteristics.",
    description_id: "Kembangkan sistem machine learning untuk mengotentikasi lukisan antik dengan menganalisis gaya artistik, pola sapuan kuas, dan karakteristik material.",
    difficulty: "hard",
    topic: "computer_vision",
    colab_url: "https://colab.research.google.com/drive/1example5",
    competition: "ioai"
  },
  %{
    title_en: "Pixel Parsimony Optimization",
    title_id: "Optimasi Piksel Hemat",
    description_en: "Optimize image representations to minimize pixel usage while maintaining visual quality. Implement compression and reconstruction techniques.",
    description_id: "Optimalkan representasi gambar untuk meminimalkan penggunaan piksel sambil mempertahankan kualitas visual. Implementasikan teknik kompresi dan rekonstruksi.",
    difficulty: "hard",
    topic: "optimization",
    colab_url: "https://colab.research.google.com/drive/1example6",
    competition: "ioai"
  },
  # ML Basics Problems (for NOAI Preliminary)
  %{
    title_en: "Linear Regression from Scratch",
    title_id: "Regresi Linear dari Awal",
    description_en: "Implement linear regression using gradient descent without using scikit-learn. Understand the math behind the algorithm and visualize the learning process.",
    description_id: "Implementasikan regresi linear menggunakan gradient descent tanpa scikit-learn. Pahami matematika di balik algoritma dan visualisasikan proses pembelajaran.",
    difficulty: "easy",
    topic: "ml_basics",
    colab_url: "https://colab.research.google.com/drive/1example7",
    competition: "noai_prelim"
  },
  %{
    title_en: "Decision Tree Classifier",
    title_id: "Classifier Decision Tree",
    description_en: "Build a decision tree classifier for a multi-class classification problem. Implement tree visualization and analyze feature importance.",
    description_id: "Bangun classifier decision tree untuk masalah klasifikasi multi-kelas. Implementasikan visualisasi tree dan analisis importance fitur.",
    difficulty: "easy",
    topic: "ml_basics",
    colab_url: "https://colab.research.google.com/drive/1example8",
    competition: "noai_prelim"
  },
  %{
    title_en: "K-Means Clustering",
    title_id: "Clustering K-Means",
    description_en: "Apply K-means clustering to segment customer data. Determine optimal K using the elbow method and silhouette analysis.",
    description_id: "Terapkan clustering K-means untuk segmentasi data pelanggan. Tentukan K optimal menggunakan metode elbow dan analisis silhouette.",
    difficulty: "easy",
    topic: "ml_basics",
    colab_url: "https://colab.research.google.com/drive/1example9",
    competition: "noai_prelim"
  },
  %{
    title_en: "Cross-Validation and Model Selection",
    title_id: "Cross-Validation dan Pemilihan Model",
    description_en: "Compare multiple ML models using k-fold cross-validation. Implement proper train/validation/test splits and evaluate model performance.",
    description_id: "Bandingkan beberapa model ML menggunakan k-fold cross-validation. Implementasikan pembagian train/validation/test yang tepat dan evaluasi performa model.",
    difficulty: "medium",
    topic: "ml_basics",
    colab_url: "https://colab.research.google.com/drive/1example10",
    competition: "noai_prelim"
  },
  # Neural Network Problems
  %{
    title_en: "Build a Simple Neural Network",
    title_id: "Bangun Neural Network Sederhana",
    description_en: "Create a multi-layer perceptron from scratch using NumPy. Implement forward propagation, backpropagation, and gradient descent.",
    description_id: "Buat multi-layer perceptron dari awal menggunakan NumPy. Implementasikan forward propagation, backpropagation, dan gradient descent.",
    difficulty: "medium",
    topic: "neural_networks",
    colab_url: "https://colab.research.google.com/drive/1example11",
    competition: "noai_final"
  },
  %{
    title_en: "MNIST Digit Classification",
    title_id: "Klasifikasi Digit MNIST",
    description_en: "Train a convolutional neural network to classify handwritten digits from the MNIST dataset using PyTorch.",
    description_id: "Latih convolutional neural network untuk mengklasifikasikan digit tulisan tangan dari dataset MNIST menggunakan PyTorch.",
    difficulty: "medium",
    topic: "neural_networks",
    colab_url: "https://colab.research.google.com/drive/1example12",
    competition: "noai_final"
  },
  %{
    title_en: "Transfer Learning with ResNet",
    title_id: "Transfer Learning dengan ResNet",
    description_en: "Fine-tune a pre-trained ResNet model for a custom image classification task. Learn about transfer learning best practices.",
    description_id: "Fine-tune model ResNet yang sudah dilatih untuk tugas klasifikasi gambar kustom. Pelajari best practices transfer learning.",
    difficulty: "medium",
    topic: "deep_learning",
    colab_url: "https://colab.research.google.com/drive/1example13",
    competition: "noai_final"
  },
  # NLP Problems
  %{
    title_en: "Sentiment Analysis with BERT",
    title_id: "Analisis Sentimen dengan BERT",
    description_en: "Fine-tune BERT for sentiment analysis on product reviews. Implement text preprocessing and model evaluation.",
    description_id: "Fine-tune BERT untuk analisis sentimen pada review produk. Implementasikan preprocessing teks dan evaluasi model.",
    difficulty: "hard",
    topic: "nlp",
    colab_url: "https://colab.research.google.com/drive/1example14",
    competition: "osn_ai"
  },
  %{
    title_en: "Text Generation with GPT",
    title_id: "Generasi Teks dengan GPT",
    description_en: "Explore text generation using GPT-2. Learn about prompting, temperature, and sampling strategies for controlled generation.",
    description_id: "Eksplorasi generasi teks menggunakan GPT-2. Pelajari prompting, temperature, dan strategi sampling untuk generasi terkontrol.",
    difficulty: "hard",
    topic: "nlp",
    colab_url: "https://colab.research.google.com/drive/1example15",
    competition: "osn_ai"
  },
  %{
    title_en: "Question Answering System",
    title_id: "Sistem Menjawab Pertanyaan",
    description_en: "Build a question answering system using transformers. Implement context-based QA with BERT or similar models.",
    description_id: "Bangun sistem menjawab pertanyaan menggunakan transformers. Implementasikan QA berbasis konteks dengan BERT atau model serupa.",
    difficulty: "hard",
    topic: "nlp",
    colab_url: "https://colab.research.google.com/drive/1example16",
    competition: "ioai"
  },
  # Computer Vision Problems
  %{
    title_en: "Object Detection with YOLO",
    title_id: "Deteksi Objek dengan YOLO",
    description_en: "Implement real-time object detection using YOLO. Train on custom dataset and evaluate detection performance.",
    description_id: "Implementasikan deteksi objek real-time menggunakan YOLO. Latih pada dataset kustom dan evaluasi performa deteksi.",
    difficulty: "hard",
    topic: "computer_vision",
    colab_url: "https://colab.research.google.com/drive/1example17",
    competition: "osn_ai"
  },
  %{
    title_en: "Image Segmentation",
    title_id: "Segmentasi Gambar",
    description_en: "Perform semantic segmentation on satellite images. Use U-Net architecture for pixel-wise classification.",
    description_id: "Lakukan segmentasi semantik pada gambar satelit. Gunakan arsitektur U-Net untuk klasifikasi pixel-wise.",
    difficulty: "hard",
    topic: "computer_vision",
    colab_url: "https://colab.research.google.com/drive/1example18",
    competition: "ioai"
  },
  %{
    title_en: "Vision Transformer (ViT)",
    title_id: "Vision Transformer (ViT)",
    description_en: "Implement and train a Vision Transformer for image classification. Compare with CNN-based approaches.",
    description_id: "Implementasikan dan latih Vision Transformer untuk klasifikasi gambar. Bandingkan dengan pendekatan berbasis CNN.",
    difficulty: "hard",
    topic: "transformers",
    colab_url: "https://colab.research.google.com/drive/1example19",
    competition: "ioai"
  },
  # Python Basics
  %{
    title_en: "NumPy Array Operations",
    title_id: "Operasi Array NumPy",
    description_en: "Master NumPy array operations including broadcasting, slicing, and vectorization. Essential for efficient ML implementations.",
    description_id: "Kuasai operasi array NumPy termasuk broadcasting, slicing, dan vectorization. Penting untuk implementasi ML yang efisien.",
    difficulty: "easy",
    topic: "python_basics",
    colab_url: "https://colab.research.google.com/drive/1example20",
    competition: "noai_prelim"
  },
  %{
    title_en: "Pandas Data Manipulation",
    title_id: "Manipulasi Data Pandas",
    description_en: "Learn data cleaning, transformation, and analysis with Pandas. Work with real-world datasets and missing values.",
    description_id: "Pelajari pembersihan data, transformasi, dan analisis dengan Pandas. Bekerja dengan dataset dunia nyata dan nilai yang hilang.",
    difficulty: "easy",
    topic: "python_basics",
    colab_url: "https://colab.research.google.com/drive/1example21",
    competition: "noai_prelim"
  },
  %{
    title_en: "Data Visualization with Matplotlib",
    title_id: "Visualisasi Data dengan Matplotlib",
    description_en: "Create informative visualizations for ML results. Learn to plot training curves, confusion matrices, and feature distributions.",
    description_id: "Buat visualisasi informatif untuk hasil ML. Pelajari cara plot kurva training, confusion matrix, dan distribusi fitur.",
    difficulty: "easy",
    topic: "python_basics",
    colab_url: "https://colab.research.google.com/drive/1example22",
    competition: "noai_prelim"
  }
]

# Insert problems
for problem_attrs <- problems do
  %Problem{}
  |> Problem.changeset(problem_attrs)
  |> Repo.insert!()
end

IO.puts("Inserted #{length(problems)} problems")

# Seed MCQ Questions for NOAI Preliminary practice
mcq_questions = [
  # ML Basics MCQs
  %{
    question_en: "What is the purpose of dropout in neural networks?",
    question_id: "Apa tujuan dropout dalam neural network?",
    option_a_en: "To prevent overfitting by randomly setting neurons to zero",
    option_a_id: "Untuk mencegah overfitting dengan mengatur neuron ke nol secara acak",
    option_b_en: "To increase training speed",
    option_b_id: "Untuk meningkatkan kecepatan training",
    option_c_en: "To add more neurons to the network",
    option_c_id: "Untuk menambah neuron ke network",
    option_d_en: "To reduce the model size for deployment",
    option_d_id: "Untuk mengurangi ukuran model untuk deployment",
    correct_answer: "A",
    explanation_en: "Dropout is a regularization technique that randomly sets a fraction of neurons to zero during training, which helps prevent overfitting by reducing co-adaptation of neurons.",
    explanation_id: "Dropout adalah teknik regularisasi yang secara acak mengatur sebagian neuron ke nol selama training, yang membantu mencegah overfitting dengan mengurangi co-adaptation neuron.",
    topic: "neural_networks",
    difficulty: "medium",
    competition: "noai_prelim"
  },
  %{
    question_en: "Which algorithm is best suited for clustering unlabeled data?",
    question_id: "Algoritma mana yang paling cocok untuk clustering data tanpa label?",
    option_a_en: "Linear Regression",
    option_a_id: "Regresi Linear",
    option_b_en: "K-Means Clustering",
    option_b_id: "Clustering K-Means",
    option_c_en: "Logistic Regression",
    option_c_id: "Regresi Logistik",
    option_d_en: "Naive Bayes",
    option_d_id: "Naive Bayes",
    correct_answer: "B",
    explanation_en: "K-Means is an unsupervised learning algorithm specifically designed for clustering unlabeled data into K distinct groups based on feature similarity.",
    explanation_id: "K-Means adalah algoritma unsupervised learning yang dirancang khusus untuk clustering data tanpa label menjadi K kelompok berbeda berdasarkan kemiripan fitur.",
    topic: "ml_basics",
    difficulty: "easy",
    competition: "noai_prelim"
  },
  %{
    question_en: "What is the vanishing gradient problem?",
    question_id: "Apa masalah vanishing gradient?",
    option_a_en: "When gradients become extremely small during backpropagation, making learning very slow",
    option_a_id: "Ketika gradient menjadi sangat kecil selama backpropagation, membuat pembelajaran sangat lambat",
    option_b_en: "When the model becomes too large to fit in memory",
    option_b_id: "Ketika model menjadi terlalu besar untuk muat di memori",
    option_c_en: "When training data disappears from the dataset",
    option_c_id: "Ketika data training menghilang dari dataset",
    option_d_en: "When the model forgets what it learned",
    option_d_id: "Ketika model lupa apa yang dipelajari",
    correct_answer: "A",
    explanation_en: "The vanishing gradient problem occurs in deep networks when gradients become exponentially small as they propagate backward through many layers, making it difficult to train early layers.",
    explanation_id: "Masalah vanishing gradient terjadi di network dalam ketika gradient menjadi sangat kecil secara eksponensial saat propagasi mundur melalui banyak layer, membuat sulit melatih layer awal.",
    topic: "neural_networks",
    difficulty: "medium",
    competition: "noai_prelim"
  },
  %{
    question_en: "What does the 'C' parameter control in SVM?",
    question_id: "Apa yang dikontrol parameter 'C' di SVM?",
    option_a_en: "The trade-off between margin size and classification errors",
    option_a_id: "Trade-off antara ukuran margin dan error klasifikasi",
    option_b_en: "The number of clusters",
    option_b_id: "Jumlah cluster",
    option_c_en: "The learning rate",
    option_c_id: "Learning rate",
    option_d_en: "The depth of the kernel",
    option_d_id: "Kedalaman kernel",
    correct_answer: "A",
    explanation_en: "The C parameter in SVM controls the trade-off between maximizing the margin and minimizing classification errors. A larger C prioritizes correct classification over margin size.",
    explanation_id: "Parameter C di SVM mengontrol trade-off antara memaksimalkan margin dan meminimalkan error klasifikasi. C yang lebih besar memprioritaskan klasifikasi benar dibanding ukuran margin.",
    topic: "ml_basics",
    difficulty: "medium",
    competition: "noai_prelim"
  },
  %{
    question_en: "What is the output of a softmax function?",
    question_id: "Apa output dari fungsi softmax?",
    option_a_en: "Probability distribution summing to 1",
    option_a_id: "Distribusi probabilitas yang berjumlah 1",
    option_b_en: "Binary values (0 or 1)",
    option_b_id: "Nilai biner (0 atau 1)",
    option_c_en: "Any real number",
    option_c_id: "Sembarang bilangan real",
    option_d_en: "Only positive integers",
    option_d_id: "Hanya bilangan bulat positif",
    correct_answer: "A",
    explanation_en: "Softmax converts a vector of real numbers into a probability distribution where all values are between 0 and 1, and sum to 1.",
    explanation_id: "Softmax mengkonversi vektor bilangan real menjadi distribusi probabilitas di mana semua nilai antara 0 dan 1, dan berjumlah 1.",
    topic: "neural_networks",
    difficulty: "easy",
    competition: "noai_prelim"
  },
  %{
    question_en: "Which metric is most appropriate for imbalanced classification?",
    question_id: "Metrik mana yang paling tepat untuk klasifikasi tidak seimbang?",
    option_a_en: "Accuracy",
    option_a_id: "Akurasi",
    option_b_en: "F1 Score",
    option_b_id: "Skor F1",
    option_c_en: "Mean Squared Error",
    option_c_id: "Mean Squared Error",
    option_d_en: "R-squared",
    option_d_id: "R-squared",
    correct_answer: "B",
    explanation_en: "F1 Score is the harmonic mean of precision and recall, making it more appropriate for imbalanced datasets where accuracy can be misleading.",
    explanation_id: "Skor F1 adalah rata-rata harmonik dari precision dan recall, membuatnya lebih tepat untuk dataset tidak seimbang di mana akurasi bisa menyesatkan.",
    topic: "ml_basics",
    difficulty: "medium",
    competition: "noai_prelim"
  },
  %{
    question_en: "What is the purpose of batch normalization?",
    question_id: "Apa tujuan batch normalization?",
    option_a_en: "To normalize inputs to each layer, improving training stability",
    option_a_id: "Untuk normalisasi input ke setiap layer, meningkatkan stabilitas training",
    option_b_en: "To reduce the batch size",
    option_b_id: "Untuk mengurangi ukuran batch",
    option_c_en: "To increase the number of parameters",
    option_c_id: "Untuk meningkatkan jumlah parameter",
    option_d_en: "To convert data to binary format",
    option_d_id: "Untuk mengkonversi data ke format biner",
    correct_answer: "A",
    explanation_en: "Batch normalization normalizes the inputs of each layer to have zero mean and unit variance, which helps stabilize and accelerate training.",
    explanation_id: "Batch normalization menormalisasi input setiap layer agar memiliki mean nol dan variance satu, yang membantu menstabilkan dan mempercepat training.",
    topic: "neural_networks",
    difficulty: "medium",
    competition: "noai_prelim"
  },
  %{
    question_en: "What does the 'attention mechanism' in transformers do?",
    question_id: "Apa yang dilakukan 'attention mechanism' di transformers?",
    option_a_en: "Allows the model to focus on relevant parts of the input when generating each output",
    option_a_id: "Memungkinkan model fokus pada bagian relevan dari input saat menghasilkan setiap output",
    option_b_en: "Speeds up the training process",
    option_b_id: "Mempercepat proses training",
    option_c_en: "Reduces the model size",
    option_c_id: "Mengurangi ukuran model",
    option_d_en: "Converts text to images",
    option_d_id: "Mengkonversi teks ke gambar",
    correct_answer: "A",
    explanation_en: "Attention mechanism allows the model to dynamically weight different parts of the input sequence, focusing on the most relevant information for each output token.",
    explanation_id: "Attention mechanism memungkinkan model untuk secara dinamis memberi bobot berbeda pada bagian-bagian input sequence, fokus pada informasi paling relevan untuk setiap output token.",
    topic: "transformers",
    difficulty: "medium",
    competition: "noai_prelim"
  },
  %{
    question_en: "What is the difference between BERT and GPT?",
    question_id: "Apa perbedaan antara BERT dan GPT?",
    option_a_en: "BERT is bidirectional, GPT is unidirectional (left-to-right)",
    option_a_id: "BERT bidirectional, GPT unidirectional (kiri ke kanan)",
    option_b_en: "BERT is for images, GPT is for text",
    option_b_id: "BERT untuk gambar, GPT untuk teks",
    option_c_en: "BERT is smaller than GPT",
    option_c_id: "BERT lebih kecil dari GPT",
    option_d_en: "There is no difference",
    option_d_id: "Tidak ada perbedaan",
    correct_answer: "A",
    explanation_en: "BERT uses bidirectional attention to understand context from both directions, while GPT uses causal (left-to-right) attention for autoregressive text generation.",
    explanation_id: "BERT menggunakan attention bidirectional untuk memahami konteks dari kedua arah, sementara GPT menggunakan attention causal (kiri ke kanan) untuk generasi teks autoregressive.",
    topic: "nlp",
    difficulty: "medium",
    competition: "noai_prelim"
  },
  %{
    question_en: "What is transfer learning?",
    question_id: "Apa itu transfer learning?",
    option_a_en: "Using a pre-trained model as a starting point for a new task",
    option_a_id: "Menggunakan model yang sudah dilatih sebagai titik awal untuk tugas baru",
    option_b_en: "Transferring data between computers",
    option_b_id: "Mentransfer data antar komputer",
    option_c_en: "Moving model weights to a different server",
    option_c_id: "Memindahkan bobot model ke server berbeda",
    option_d_en: "Converting one model architecture to another",
    option_d_id: "Mengkonversi satu arsitektur model ke lainnya",
    correct_answer: "A",
    explanation_en: "Transfer learning involves taking a model trained on one task (usually with large data) and fine-tuning it for a different but related task, leveraging learned features.",
    explanation_id: "Transfer learning melibatkan mengambil model yang dilatih pada satu tugas (biasanya dengan data besar) dan fine-tuning untuk tugas berbeda tapi terkait, memanfaatkan fitur yang dipelajari.",
    topic: "deep_learning",
    difficulty: "easy",
    competition: "noai_prelim"
  }
]

# Insert MCQ questions
for question_attrs <- mcq_questions do
  %Question{}
  |> Question.changeset(question_attrs)
  |> Repo.insert!()
end

IO.puts("Inserted #{length(mcq_questions)} MCQ questions")
IO.puts("Database seeding completed!")

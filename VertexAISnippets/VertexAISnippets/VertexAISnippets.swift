// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

// [START import_vertexai]
import FirebaseVertexAI
// [END import_vertexai]

class Snippets {

  var model: GenerativeModel!

  func initializeModel() {
    // [START initialize_model]
    // Initialize the Vertex AI service
    let vertex = VertexAI.vertexAI()

    // Initialize the generative model with a model that supports your use case
    // Gemini 1.5 Pro is versatile and can accept both text-only or multimodal prompt inputs
    let model = vertex.generativeModel(modelName: "gemini-1.5-pro-preview-0409")
    // [END initialize_model]

    self.model = model
  }

  func callGemini() async throws {
    // [START call_gemini]
    // Provide a prompt that contains text
    let prompt = "Write a story about a magic backpack."

    // To generate text output, call generateContent with the text input
    let response = try await model.generateContent(prompt)
    if let text = response.text {
      print(text)
    }
    // [END call_gemini]
  }

  func callGeminiStreaming() async throws {
    // [START call_gemini_streaming]
    // Provide a prompt that contains text
    let prompt = "Write a story about a magic backpack."

    // To stream generated text output, call generateContentStream with the text input
    let contentStream = model.generateContentStream(prompt)
    for try await chunk in contentStream {
      if let text = chunk.text {
        print(text)
      }
    }
    // [END call_gemini_streaming]
  }

  func sendTextOnlyPromptStreaming() async throws {
    // [START text_only_prompt_streaming]
    // Provide a prompt that contains text
    let prompt = "Write a story about a magic backpack."

    // To stream generated text output, call generateContentStream with the text input
    let contentStream = model.generateContentStream(prompt)
    for try await chunk in contentStream {
      if let text = chunk.text {
        print(text)
      }
    }
    // [END text_only_prompt_streaming]
  }

  // Note: This is the same as the call gemini prompt, but may change in the future.
  func sendTextOnlyPromt() async throws {
    // [START text_only_prompt]
    // Provide a prompt that contains text
    let prompt = "Write a story about a magic backpack."

    // To generate text output, call generateContent with the text input
    let response = try await model.generateContent(prompt)
    if let text = response.text {
      print(text)
    }
    // [END text_only_prompt]
  }

  func sendMultimodalPromptStreaming() async throws {
    // [START multimodal_prompt_streaming]
    #if canImport(UIKit)
      guard let image = UIImage(named: "image") else { fatalError() }
    #else
      guard let image = NSImage(named: "image") else { fatalError() }
    #endif

    // Provide a text prompt to include with the image
    let prompt = "What's in this picture?"

    // To stream generated text output, call generateContentStream and pass in the prompt
    let contentStream = model.generateContentStream(image, prompt)
    for try await chunk in contentStream {
      if let text = chunk.text {
        print(text)
      }
    }
    // [END multimodal_prompt_streaming]
  }

  func sendMultimodalPrompt() async throws {
    // [START multimodal_prompt]
    // Provide a text prompt to include with the image
    #if canImport(UIKit)
      guard let image = UIImage(named: "image") else { fatalError() }
    #else
      guard let image = NSImage(named: "image") else { fatalError() }
    #endif

    let prompt = "What's in this picture?"

    // To generate text output, call generateContent and pass in the prompt
    let response = try await model.generateContent(image, prompt)
    if let text = response.text {
      print(text)
    }
    // [END multimodal_prompt]
  }

  func multiImagePromptStreaming() async throws {
    // [START two_image_prompt_streaming]
    #if canImport(UIKit)
      guard let image1 = UIImage(named: "image1") else { fatalError() }
      guard let image2 = UIImage(named: "image2") else { fatalError() }
    #else
      guard let image1 = NSImage(named: "image1") else { fatalError() }
      guard let image2 = NSImage(named: "image2") else { fatalError() }
    #endif

    // Provide a text prompt to include with the images
    let prompt = "What's different between these pictures?"

    // To stream generated text output, call generateContentStream and pass in the prompt
    let contentStream = model.generateContentStream(image1, image2, prompt)
    for try await chunk in contentStream {
      if let text = chunk.text {
        print(text)
      }
    }
    // [END two_image_prompt_streaming]
  }

  func multiImagePrompt() async throws {
    // [START two_image_prompt]
    #if canImport(UIKit)
      guard let image1 = UIImage(named: "image1") else { fatalError() }
      guard let image2 = UIImage(named: "image2") else { fatalError() }
    #else
      guard let image1 = NSImage(named: "image1") else { fatalError() }
      guard let image2 = NSImage(named: "image2") else { fatalError() }
    #endif

    // Provide a text prompt to include with the images
    let prompt = "What's different between these pictures?"

    // To generate text output, call generateContent and pass in the prompt
    let response = try await model.generateContent(image1, image2, prompt)
    if let text = response.text {
      print(text)
    }
    // [END two_image_prompt]
  }

  func textAndVideoPrompt() async throws {
    // AVFoundation support coming soon™
    // [START text_video_prompt]
    guard let fileURL = Bundle.main.url(forResource: "sample", 
                                        withExtension: "mp4") else { fatalError() }
    let video = try Data(contentsOf: fileURL)
    let prompt = "What's in this video?"
    let videoContent = ModelContent.Part.data(mimetype: "video/mp4", video)

    // To generate text output, call generateContent and pass in the prompt
    let response = try await model.generateContent(videoContent, prompt)
    if let text = response.text {
      print(text)
    }
    // [END text_video_prompt]
  }

  func textAndVideoPromptStreaming() async throws {
    // AVFoundation support coming soon™
    // [START text_video_prompt_streaming]
    guard let fileURL = Bundle.main.url(forResource: "sample",
                                        withExtension: "mp4") else { fatalError() }
    let video = try Data(contentsOf: fileURL)
    let prompt = "What's in this video?"
    let videoContent = ModelContent.Part.data(mimetype: "video/mp4", video)

    // To stream generated text output, call generateContentStream and pass in the prompt
    let contentStream = model.generateContentStream(videoContent, prompt)
    for try await chunk in contentStream {
      if let text = chunk.text {
        print(text)
      }
    }
    // [END text_video_prompt_streaming]
  }

  func chatStreaming() async throws {
    // [START chat_streaming]
    // Optionally specify existing chat history
    let history = [
      ModelContent(role: "user", parts: "Hello, I have 2 dogs in my house."),
      ModelContent(role: "model", parts: "Great to meet you. What would you like to know?"),
    ]

    // Initialize the chat with optional chat history
    let chat = model.startChat(history: history)

    // To stream generated text output, call sendMessageStream and pass in the message
    let contentStream = chat.sendMessageStream("How many paws are in my house?")
    for try await chunk in contentStream {
      if let text = chunk.text {
        print(text)
      }
    }
    // [END chat_streaming]
  }

  func chat() async throws {
    // [START chat]
    // Optionally specify existing chat history
    let history = [
      ModelContent(role: "user", parts: "Hello, I have 2 dogs in my house."),
      ModelContent(role: "model", parts: "Great to meet you. What would you like to know?"),
    ]

    // Initialize the chat with optional chat history
    let chat = model.startChat(history: history)

    // To generate text output, call sendMessage and pass in the message
    let response = try await chat.sendMessage("How many paws are in my house?")
    if let text = response.text {
      print(text)
    }
    // [END chat]
  }

  func countTokensText() async throws {
    // [START count_tokens_text]
    let response = try await model.countTokens("Why is the sky blue?")
    print("Total Tokens: \(response.totalTokens)")
    print("Total Billable Characters: \(response.totalBillableCharacters)")
    // [END count_tokens_text]
  }

  func countTokensTextAndImage() async throws {
#if canImport(UIKit)
  guard let image = UIImage(named: "image") else { fatalError() }
#else
  guard let image = NSImage(named: "image") else { fatalError() }
#endif
    // [START count_tokens_text_image]
    let response = try await model.countTokens(image, "What's in this picture?")
    print("Total Tokens: \(response.totalTokens)")
    print("Total Billable Characters: \(response.totalBillableCharacters)")
    // [START count_tokens_text_image]
  }

  func countTokensMultiImage() async throws {
#if canImport(UIKit)
  guard let image1 = UIImage(named: "image1") else { fatalError() }
  guard let image2 = UIImage(named: "image2") else { fatalError() }
#else
  guard let image1 = NSImage(named: "image1") else { fatalError() }
  guard let image2 = NSImage(named: "image2") else { fatalError() }
#endif
    // [START count_tokens_multi_image]
    let response = try await model.countTokens(image1, image2, "What's in this picture?")
    print("Total Tokens: \(response.totalTokens)")
    print("Total Billable Characters: \(response.totalBillableCharacters)")
    // [END count_tokens_multi_image]
  }

  func countTokensChat() async throws {
    // [START count_tokens_chat]
    let chat = model.startChat()
    let history = chat.history
    let message = try ModelContent(role: "user", "Why is the sky blue?")
    let contents = history + [message]
    let response = try await model.countTokens(contents)
    print("Total Tokens: \(response.totalTokens)")
    print("Total Billable Characters: \(response.totalBillableCharacters)")
    // [END count_tokens_chat]
  }

  func setSafetySetting() {
    // [START set_safety_setting]
    let model = VertexAI.vertexAI().generativeModel(
      modelName: "MODEL_NAME",
      safetySettings: [
        SafetySetting(harmCategory: .harassment, threshold: .blockOnlyHigh)
      ]
    )
    // [END set_safety_setting]
  }

  func setMultipleSafetySettings() {
    // [START set_safety_settings]
    let harassmentSafety = SafetySetting(harmCategory: .harassment, threshold: .blockOnlyHigh)
    let hateSpeechSafety = SafetySetting(harmCategory: .hateSpeech, threshold: .blockMediumAndAbove)

    let model = VertexAI.vertexAI().generativeModel(
      modelName: "MODEL_NAME",
      safetySettings: [harassmentSafety, hateSpeechSafety]
    )
    // [END set_safety_settings]
  }

}

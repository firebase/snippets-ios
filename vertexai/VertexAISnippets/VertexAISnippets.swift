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
    // Gemini 1.5 models are versatile and can be used with all API capabilities
    let model = vertex.generativeModel(modelName: "gemini-1.5-flash")
    // [END initialize_model]

    self.model = model
  }

  func configureModel() {
    let vertex = VertexAI.vertexAI()

    // [START configure_model]
    let config = GenerationConfig(
      temperature: 0.9,
      topP: 0.1,
      topK: 16,
      maxOutputTokens: 200,
      stopSequences: ["red"]
    )

    let model = vertex.generativeModel(
      modelName: "gemini-1.5-flash",
      generationConfig: config
    )
    // [END configure_model]
  }

  func safetySettings() {
    let vertex = VertexAI.vertexAI()

    // [START safety_settings]
    let model = vertex.generativeModel(
      modelName: "gemini-1.5-flash",
      safetySettings: [
        SafetySetting(harmCategory: .harassment, threshold: .blockOnlyHigh)
      ]
    )
    // [END safety_settings]
  }

  func multiSafetySettings() {
    let vertex = VertexAI.vertexAI()

    // [START multi_safety_settings]
    let harassmentSafety = SafetySetting(harmCategory: .harassment, threshold: .blockOnlyHigh)
    let hateSpeechSafety = SafetySetting(harmCategory: .hateSpeech, threshold: .blockMediumAndAbove)

    let model = vertex.generativeModel(
      modelName: "gemini-1.5-flash",
      safetySettings: [harassmentSafety, hateSpeechSafety]
    )
    // [END multi_safety_settings]
  }

  func sendTextOnlyPromptStreaming() async throws {
    // [START text_gen_text_only_prompt_streaming]
    // Provide a prompt that contains text
    let prompt = "Write a story about a magic backpack."

    // To stream generated text output, call generateContentStream with the text input
    let contentStream = model.generateContentStream(prompt)
    for try await chunk in contentStream {
      if let text = chunk.text {
        print(text)
      }
    }
    // [END text_gen_text_only_prompt_streaming]
  }

  func sendTextOnlyPromt() async throws {
    // [START text_gen_text_only_prompt]
    // Provide a prompt that contains text
    let prompt = "Write a story about a magic backpack."

    // To generate text output, call generateContent with the text input
    let response = try await model.generateContent(prompt)
    if let text = response.text {
      print(text)
    }
    // [END text_gen_text_only_prompt]
  }

  func sendMultimodalPromptStreaming() async throws {
    // [START text_gen_multimodal_one_image_prompt_streaming]
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
    // [END text_gen_multimodal_one_image_prompt_streaming]
  }

  func sendMultimodalPrompt() async throws {
    // [START text_gen_multimodal_one_image_prompt]
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
    // [END text_gen_multimodal_one_image_prompt]
  }

  func multiImagePromptStreaming() async throws {
    // [START text_gen_multimodal_multi_image_prompt_streaming]
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
    // [END text_gen_multimodal_multi_image_prompt_streaming]
  }

  func multiImagePrompt() async throws {
    // [START text_gen_multimodal_multi_image_prompt]
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
    // [END text_gen_multimodal_multi_image_prompt]
  }

  func textAndVideoPrompt() async throws {
    // [START text_gen_multimodal_video_prompt]
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
    // [END text_gen_multimodal_video_prompt]
  }

  func textAndVideoPromptStreaming() async throws {
    // [START text_gen_multimodal_video_prompt_streaming]
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
    // [END text_gen_multimodal_video_prompt_streaming]
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
    // [END count_tokens_text_image]
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
    // [START set_one_safety_setting]
    let model = VertexAI.vertexAI().generativeModel(
      modelName: "gemini-1.5-flash",
      safetySettings: [
        SafetySetting(harmCategory: .harassment, threshold: .blockOnlyHigh)
      ]
    )
    // [END set_one_safety_setting]
  }

  func setMultipleSafetySettings() {
    // [START set_multi_safety_settings]
    let harassmentSafety = SafetySetting(harmCategory: .harassment, threshold: .blockOnlyHigh)
    let hateSpeechSafety = SafetySetting(harmCategory: .hateSpeech, threshold: .blockMediumAndAbove)

    let model = VertexAI.vertexAI().generativeModel(
      modelName: "gemini-1.5-flash",
      safetySettings: [harassmentSafety, hateSpeechSafety]
    )
    // [END set_multi_safety_settings]
  }

  // MARK: - Function Calling

  func functionCalling() async throws {
    // [START create_function]
    func makeAPIRequest(currencyFrom: String, currencyTo: String) -> JSONObject {
      // This hypothetical API returns a JSON such as:
      // {"base":"USD","rates":{"SEK": 10.99}}
      return [
        "base": .string(currencyFrom),
        "rates": .object([currencyTo: .number(10.99)]),
      ]
    }
    // [END create_function]

    // [START create_function_metadata]
    let getExchangeRate = FunctionDeclaration(
      name: "getExchangeRate",
      description: "Get the exchange rate for currencies between countries",
      parameters: [
        "currencyFrom": Schema(
          type: .string,
          description: "The currency to convert from."
        ),
        "currencyTo": Schema(
          type: .string,
          description: "The currency to convert to."
        ),
      ],
      requiredParameters: ["currencyFrom", "currencyTo"]
    )
    // [END create_function_metadata]

    // [START initialize_model_function]
    // Initialize the Vertex AI service
    let vertex = VertexAI.vertexAI()
    
    // Initialize the generative model
    // Use a model that supports function calling, like a Gemini 1.5 model.
    let model = vertex.generativeModel(
      modelName: "gemini-1.5-flash",
      // Specify the function declaration.
      tools: [Tool(functionDeclarations: [getExchangeRate])]
    )
    // [END initialize_model_function]

    // [START generate_function_call]
    let chat = model.startChat()

    let prompt = "How much is 50 US dollars worth in Swedish krona?"

    // Send the message to the generative model
    let response1 = try await chat.sendMessage(prompt)

    // Check if the model responded with a function call
    guard let functionCall = response1.functionCalls.first else {
      fatalError("Model did not respond with a function call.")
    }
    // Print an error if the returned function was not declared
    guard functionCall.name == "getExchangeRate" else {
      fatalError("Unexpected function called: \(functionCall.name)")
    }
    // Verify that the names and types of the parameters match the declaration
    guard case let .string(currencyFrom) = functionCall.args["currencyFrom"] else {
      fatalError("Missing argument: currencyFrom")
    }
    guard case let .string(currencyTo) = functionCall.args["currencyTo"] else {
      fatalError("Missing argument: currencyTo")
    }

    // Call the hypothetical API
    let apiResponse = makeAPIRequest(currencyFrom: currencyFrom, currencyTo: currencyTo)

    // Send the API response back to the model so it can generate a text response that can be
    // displayed to the user.
    let response = try await chat.sendMessage([ModelContent(
      role: "function",
      parts: [.functionResponse(FunctionResponse(
        name: functionCall.name,
        response: apiResponse
      ))]
    )])

    // Log the text response.
    guard let modelResponse = response.text else {
      fatalError("Model did not respond with text.")
    }
    print(modelResponse)
    // [END generate_function_call]
  }

  func functionCallingModes() {
    let getExchangeRate = FunctionDeclaration(
      name: "getExchangeRate",
      description: "Get the exchange rate for currencies between countries",
      parameters: nil,
      requiredParameters: nil
    )

    // [START function_modes]
    let model = VertexAI.vertexAI().generativeModel(
      // Setting a function calling mode is only available in Gemini 1.5 Pro
      modelName: "gemini-1.5-pro",
      // Pass the function declaration
      tools: [Tool(functionDeclarations: [getExchangeRate])],
      toolConfig: ToolConfig(
        functionCallingConfig: FunctionCallingConfig(
          // Only call functions (model won't generate text)
          mode: FunctionCallingConfig.Mode.any,
          // This should only be set when the Mode is .any.
          allowedFunctionNames: ["getExchangeRate"]
        )
      )
    )
    // [END function_modes]
  }

}

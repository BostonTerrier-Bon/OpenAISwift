//
//  File.swift
//
//
//  Created by Bogdan Farca on 02.03.2023.
//

import Foundation

/// An enumeration of possible roles in a chat conversation.
public enum ChatRole: String, Codable {
    /// The role for the system that manages the chat interface.
    case system
    /// The role for the human user who initiates the chat.
    case user
    /// The role for the artificial assistant who responds to the user.
    case assistant
    /// The role for the function that generates the response.
    case function
}

/// A structure that represents a single message in a chat conversation.
public struct ChatMessage: Codable {
    /// The role of the sender of the message.
    public let role: ChatRole
    /// The content of the message. content is required for all messages except assistant messages with function calls.
    public let content: String?
    /// The name is required if role is function / maximum length of 64 characters
    public let name: String?
    /// The name and arguments of a function that should be called
    public let functionCall: ChatFunctionCall?

    /// Creates a new chat message with a given role and content.
    /// - Parameters:
    ///   - role: The role of the sender of the message.
    ///   - content: The content of the message. Required for all messages except assistant messages with function calls.
    public init(role: ChatRole, content: String? = nil, name: String? = nil, functionCall: ChatFunctionCall? = nil) {
        self.role = role
        self.content = content
        self.name = name
        self.functionCall = functionCall
    }
    
    enum CodingKeys: String, CodingKey {
        case role
        case content
        case name
        case functionCall = "function_call"
    }
}

/// A structure that represents a function call within a chat message.
public struct ChatFunctionCall: Codable {
    /// The name of the function to be called.
    public let name: String
    /// The arguments to pass to the function, if any.
    public let arguments: String?

    public init(name: String, arguments: String? = nil) {
        self.name = name
        self.arguments = arguments
    }
}

/// A structure that encapsulates the various functions that can be called within a chat message.
//public struct ChatFunctions: Codable {
//    /// The name of the function.
//    public let name: String
//    /// An optional description of the function.
//    public let description: String?
//    /// An optional dictionary of parameters that the function can accept, with their respective possible values.
//    public let parameters: [String: ChatFunctionCallParameterValue]?\
//
//}
/// A structure that encapsulates the various functions that can be called within a chat message.
///
public protocol ChatFunctionArgs: Codable {
    var type: String {get set}
}
public struct ChatFunctions<T: ChatFunctionArgs>: Codable {
    /// The name of the function.
    public let name: String
    /// An optional description of the function.
    public let description: String?
    /// An optional dictionary of parameters that the function can accept, with their respective possible values.
    public let parameters: T?

    public init(name: String, description: String? = nil, parameters: T? = nil) {
        self.name = name
        self.description = description
        self.parameters = parameters
    }
}

///// An enumeration that defines the various types of values a function parameter can take within a chat message.
//public indirect enum ChatFunctionCallParameterValue: Codable {
//    /// A parameter value represented as a string.
//    case string(String)
//    /// A parameter value represented as a dictionary.
//    case dictionary([String: ChatFunctionCallParameterValue])
//    /// A parameter value represented as a array.
//    case array([String])
//    /// A parameter value represented as a boolean.
//    case bool(Bool)
//    /// A parameter value represented as a number.
//    case number(Double)
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if let value = try? container.decode(String.self) {
//            self = .string(value)
//        } else if let value = try? container.decode(Bool.self) {
//            self = .bool(value)
//        } else if let value = try? container.decode(Double.self) {
//            self = .number(value)
//        } else if let value = try? container.decode([String: ChatFunctionCallParameterValue].self) {
//            self = .dictionary(value)
//        } else if let value = try? container.decode([String].self) {
//            self = .array(value)
//        } else {
//            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid value")
//        }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        switch self {
//        case .string(let value):
//            try container.encode(value)
//        case .dictionary(let value):
//            try container.encode(value)
//        case .array(let value):
//            try container.encode(value)
//        case .bool(let value):
//            try container.encode(value)
//        case .number(let value):
//            try container.encode(value)
//        }
//    }
//}




/// A structure that represents a chat conversation.
public struct ChatConversation: Encodable {
    /// The name or identifier of the user who initiates the chat. Optional if not provided by the user interface.
    let user: String?

    /// The messages to generate chat completions for. Ordered chronologically from oldest to newest.
    let messages: [ChatMessage]
    
    /// The ID of the model used by the assistant to generate responses. See OpenAI documentation for details on which models work with the Chat API.
    let model: String

    /// A parameter that controls how random or deterministic the responses are, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. Optional, defaults to 1.
    let temperature: Double?

    /// A parameter that controls how diverse or narrow-minded the responses are, between 0 and 1. Higher values like 0.9 mean only the tokens comprising the top 90% probability mass are considered, while lower values like 0.1 mean only the top 10%. Optional, defaults to 1.
    let topProbabilityMass: Double?

    /// How many chat completion choices to generate for each input message. Optional, defaults to 1.
    let choices: Int?

    /// An array of up to 4 sequences where the API will stop generating further tokens. Optional.
    let stop: [String]?

    /// The maximum number of tokens to generate in the chat completion. The total length of input tokens and generated tokens is limited by the model's context length. Optional.
    let maxTokens: Int?

    /// A parameter that penalizes new tokens based on whether they appear in the text so far, between -2 and 2. Positive values increase the model's likelihood to talk about new topics. Optional if not specified by default or by user input. Optional, defaults to 0.
    let presencePenalty: Double?

    /// A parameter that penalizes new tokens based on their existing frequency in the text so far, between -2 and 2. Positive values decrease the model's likelihood to repeat the same line verbatim. Optional if not specified by default or by user input. Optional, defaults to 0.
    let frequencyPenalty: Double?

    /// Modify the likelihood of specified tokens appearing in the completion. Maps tokens (specified by their token ID in the OpenAI Tokenizer—not English words) to an associated bias value from -100 to 100. Values between -1 and 1 should decrease or increase likelihood of selection; values like -100 or 100 should result in a ban or exclusive selection of the relevant token.
    let logitBias: [Int: Double]?
    

    enum CodingKeys: String, CodingKey {
        case user
        case messages
        case model
        case temperature
        case topProbabilityMass = "top_p"
        case choices = "n"
        case stop
        case maxTokens = "max_tokens"
        case presencePenalty = "presence_penalty"
        case frequencyPenalty = "frequency_penalty"
        case logitBias = "logit_bias"
    }
}


public struct ChatConversationFunction<T: ChatFunctionArgs>: Encodable {
    /// The name or identifier of the user who initiates the chat. Optional if not provided by the user interface.
    let user: String?

    /// The messages to generate chat completions for. Ordered chronologically from oldest to newest.
    let messages: [ChatMessage]

    var functions: [ChatFunctions<T>]? = nil
    
    /// The ID of the model used by the assistant to generate responses. See OpenAI documentation for details on which models work with the Chat API.
    let model: String

    /// A parameter that controls how random or deterministic the responses are, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. Optional, defaults to 1.
    let temperature: Double?

    /// A parameter that controls how diverse or narrow-minded the responses are, between 0 and 1. Higher values like 0.9 mean only the tokens comprising the top 90% probability mass are considered, while lower values like 0.1 mean only the top 10%. Optional, defaults to 1.
    let topProbabilityMass: Double?

    /// How many chat completion choices to generate for each input message. Optional, defaults to 1.
    let choices: Int?

    /// An array of up to 4 sequences where the API will stop generating further tokens. Optional.
    let stop: [String]?

    /// The maximum number of tokens to generate in the chat completion. The total length of input tokens and generated tokens is limited by the model's context length. Optional.
    let maxTokens: Int?

    /// A parameter that penalizes new tokens based on whether they appear in the text so far, between -2 and 2. Positive values increase the model's likelihood to talk about new topics. Optional if not specified by default or by user input. Optional, defaults to 0.
    let presencePenalty: Double?

    /// A parameter that penalizes new tokens based on their existing frequency in the text so far, between -2 and 2. Positive values decrease the model's likelihood to repeat the same line verbatim. Optional if not specified by default or by user input. Optional, defaults to 0.
    let frequencyPenalty: Double?

    /// Modify the likelihood of specified tokens appearing in the completion. Maps tokens (specified by their token ID in the OpenAI Tokenizer—not English words) to an associated bias value from -100 to 100. Values between -1 and 1 should decrease or increase likelihood of selection; values like -100 or 100 should result in a ban or exclusive selection of the relevant token.
    let logitBias: [Int: Double]?
    
//    /// Controls how the model responds to function calls
    var functionCall: String = "auto"

    enum CodingKeys: String, CodingKey {
        case user
        case messages
        case model
        case temperature
        case topProbabilityMass = "top_p"
        case choices = "n"
        case stop
        case maxTokens = "max_tokens"
        case presencePenalty = "presence_penalty"
        case frequencyPenalty = "frequency_penalty"
        case logitBias = "logit_bias"
        case functions
        case functionCall = "function_call"
    }
}

//public enum FunctionCallOrAutoOrNone: Codable {
//    case functionCall(FunctionCall?)
//    case auto
//
//    enum CodingKeys: String, CodingKey {
//        case functionCall = "function_call"
////        case auto
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        if let value = try? container.decode(FunctionCall?.self, forKey: .functionCall) {
//            self = .functionCall(value)
//        } else if let value = try? container.decode(String.self, forKey: .functionCall), value == "auto" {
//            self = .auto
//        } else {
//            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode enum."))
//        }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        switch self {
//        case .functionCall(let value):
//            if let value = value {
//                try container.encode(value, forKey: .functionCall)
//            } else {
//                try container.encode("none", forKey: .functionCall)
//            }
//        case .auto:
//            try container.encode("auto", forKey: .functionCall)
//        }
//    }
//}

public struct FunctionCall: Codable {
    public let name: String
}


public struct ChatError: Codable {
    public struct Payload: Codable {
        public let message, type: String
        public let param, code: String?
    }
    
    public let error: Payload
}

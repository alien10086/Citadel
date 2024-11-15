//
//  675756757.swift
//  Citadel
//
//  Created by 李国政 on 2024/11/14.
//
import NIOSSH
import NIO
class MyGlobalRequestDelegate: GlobalRequestDelegate {
    // 处理全球请求
    func tcpForwardingRequest(_ rquest: GlobalRequest.TCPForwardingRequest, handler: NIOSSHHandler, promise: EventLoopPromise<GlobalRequest.TCPForwardingResponse>)
//    func handleGlobalRequest(request: GlobalRequest, channel: Channel) -> EventLoopFuture<Void>
    {
        print("12313123123")
        promise.fail(NIOSSHError.ErrorType.globalRequestRefused as! Error)
//        switch request {
//        case .tcpForwarding(let localAddress, let localPort, let remoteAddress, let remotePort):
//            // 处理 TCP 转发请求
//            print("收到 TCP 转发请求: \(localAddress):\(localPort) -> \(remoteAddress):\(remotePort)")
//            
//            // 可以在此添加处理代码，响应请求
//            return channel.sendGlobalRequestResponse(.success)
//        default:
//            // 处理其他类型的请求
//            print("收到不支持的请求类型: \(request)")
//            return channel.sendGlobalRequestResponse(.failure)
//        }
    }
}

import NIO
import NIOSSH

final class DataToBufferCodec: ChannelDuplexHandler {
    typealias InboundIn = SSHChannelData
    typealias InboundOut = ByteBuffer
    typealias OutboundIn = ByteBuffer
    typealias OutboundOut = SSHChannelData

    func handlerAdded(context: ChannelHandlerContext) {
        context.channel.setOption(ChannelOptions.allowRemoteHalfClosure, value: true).whenFailure { error in
            context.fireErrorCaught(error)
        }
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let data = unwrapInboundIn(data)

        guard case let .byteBuffer(bytes) = data.data else {
            fatalError("Unexpected read type")
        }

        guard case .channel = data.type else {
            context.fireErrorCaught(SSHChannelError.invalidDataType)
            return
        }

        context.fireChannelRead(wrapInboundOut(bytes))
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let data = unwrapOutboundIn(data)
        context.write(wrapOutboundOut(SSHChannelData(type: .channel, data: .byteBuffer(data))), promise: promise)
    }
}

extension SSHClient {
    /// Creates a new direct TCP/IP channel. This channel type is used to open a TCP/IP connection to a remote host, through the remote SSH server.
    public func createDirectTCPIPChannel(
        using settings: SSHChannelType.DirectTCPIP,
        initialize: @escaping (Channel) -> EventLoopFuture<Void>
    ) async throws -> Channel {
        return try await eventLoop.flatSubmit {
            let createdChannel = self.eventLoop.makePromise(of: Channel.self)
            self.session.sshHandler.createChannel(
                createdChannel,
                channelType: .directTCPIP(settings)
            ) { channel, type in
                guard case .directTCPIP = type else {
                    return channel.eventLoop.makeFailedFuture(SSHClientError.channelCreationFailed)
                }

                return channel.pipeline.addHandler(DataToBufferCodec()).flatMap {
                    return initialize(channel)
                }
            }

            return createdChannel.futureResult
        }.get()
    }

    public func createForwardedTCPIPChannel(
        using settings: SSHChannelType.ForwardedTCPIP,
        initialize: @escaping (Channel) -> EventLoopFuture<Void>
    ) async throws -> Channel {
        return try await eventLoop.flatSubmit {
            let createdChannel = self.eventLoop.makePromise(of: Channel.self)
            self.session.sshHandler.createChannel(
                createdChannel,
                channelType: .forwardedTCPIP(settings)
            ) { channel, type in
                guard case .forwardedTCPIP = type else {
                    return channel.eventLoop.makeFailedFuture(SSHClientError.channelCreationFailed)
                }

//                return channel.pipeline.addHandler(DataToBufferCodec()).flatMap {
                return initialize(channel)
//                }
            }

            return createdChannel.futureResult
        }.get()
    }
}

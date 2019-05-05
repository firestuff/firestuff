<!--# set var="title" value="Optimistic parsing" -->
<!--# set var="date" value="2019-05-05" -->

<!--# include file="include/top.html" -->

I've been writing a [FastCGI](https://www.mit.edu/~yandros/doc/specs/fcgi-spec.html) protocol parser. The protocol is reasonably well designed (if not accurately documented), and parsing it follows a familiar pattern:

* Sequential structures/records (e.g. header followed by body)
* Stateful: subsequent parsing depends on past parsing (e.g. length field in header tells you the size of body)
* Variable length: most messages are short, but some can be long
* Stream-based: underlying protocol doesn't provide any help with message boundaries

This pattern presents an implementation challenge: how to balance efficiency with implementation complexity. It seems easy to read and parse each structure/record sequentially, but there are pitfalls and fundamental problems:

* You have to consistently handle interrupted system calls (EINTR) and [short reads](TODO) for every read()
* It only works in a thread-per-connection model
* It results in extra system calls, which are [expensive](TODO)

The solution to all three of these is the same: buffering. This can be a dirty word because it hides magic — many programmers have wondered at some point why their output didn't get written, only to discover that they're using [fopen()](https://en.cppreference.com/w/cpp/io/c/fopen) and didn't write a newline, or similar. Buffering used well, however, can keep execution in user space. Optimistic buffering can make control flow even easier to understand.

The biggest thing that makes such code ugly is handling running out of data while in the middle of parsing a structure/record. If you have some state (say, a header), preserving that state until the remaining data arrives is messy and error-prone, especially in a many-connections-per-thread model. However, you've already read that data from the socket/buffer, so you can't just throw it away. But what if you had a smarter buffer?

Consider:

    void HandleReadable() {
		buffer.Read(socket);

		while (1) {
			// Rewind any previous reads past our last commit point.
			buffer.ResetRead();

			if (!ParseHeader(buffer)) {
				break;
			}

			if (!ParseBody(buffer)) {
				break;
			}

			HandleRequest();

			// The buffer can discard any data that we've read so far.
			buffer.Commit();
		}

		// Move data to make room for the next Read().
		buffer.Consume();
	}

You still keep state between calls to this function, but it's entirely inside the buffer.

Internally, the buffer object has two pointers: one to the next byte to read, and one to the byte to rewind to. ResetRead() moves the read pointer to the rewind pointer. Commit() moves the rewind pointer to the read pointer. Consume() moves any data starting at the commit pointer to the start of the buffer, then moves the pointers back to match.

This is "optimistic" because it assumes that most of the time, we'll have a whole record to parse in the buffer. If data arrives one byte at a time, we'll waste lots of effort re-parsing the early bytes. That's not the way it works in reality for many protocols, though, and for things like FastCGI this can parse multiple records before it calls Consume(), minimizing not only syscalls but data copies.

In exchange for that risk of multiple re-parsing, we get a relatively clean, readable implementation. The `break` statements are probably the ugliest, but function return error handling patterns are a topic for another day.

Here's a simple implementation of such a smart buffer: [firebuf](https://github.com/firestuff/firebuf)

<!--# include file="include/bottom.html" -->

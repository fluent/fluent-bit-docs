---
description: The HTTP input plugin allows you to send custom records to an HTTP endpoint.
---

# HTTP

## Configuration Parameters

| **Key** | Description | default |
| :--- | :--- | :--- |
| host | The address to listen on | 0.0.0.0 |
| port | The port for Fluent Bit to listen on | 9880 |
| buffer\_max\_size | Specify the maximum buffer size in KB to receive a JSON message. | 4M |
| buffer\_chunk\_size | This sets the chunk size for incoming incoming JSON messages. These chunks are then stored/managed in the space available by buffer\_max\_size.  | 512K |

## Getting Started

The in\_http plugin all 

### Configuration File

### Command Line

#### 


# Tactical Encryption Unit

<p align="center">
  <img src="https://img.shields.io/badge/Assembly-MASM-blue?style=for-the-badge" alt="MASM"/>
  <img src="https://img.shields.io/badge/Visual%20Studio-2022-purple?style=for-the-badge" alt="Visual Studio"/>
  <img src="https://img.shields.io/badge/Platform-x86-orange?style=for-the-badge" alt="Platform"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License"/>
</p>

## 🔒 Overview

Tactical Encryption Unit is an assembly language program that provides secure communication through various classical encryption algorithms. Developed in Microsoft Macro Assembler (MASM), this command-line tool offers multiple cipher methods to protect sensitive information.

```
  _______         _   _           _   
 |__   __|       | | (_)         | |  
    | | __ _  ___| |_ _  ___ __ _| |  
    | |/ _` |/ __| __| |/ __/ _` | |  
    | | (_| | (__| |_| | (_| (_| | |  
    |_|\__,_|\___|\__|_|\___\__,_|_|  
                                      
    Encryption Unit | Secure Comms    
```

## 💡 Features

- **Multiple Cipher Support**:
  - Caesar Cipher - Shift-based substitution
  - ROT13 - Fixed 13-letter shift variant of Caesar
  - Vigenère Cipher - Polyalphabetic substitution using a keyword
  - Custom Substitution - User-defined alphabetic mapping
  - Playfair Cipher - Digraph substitution with 5x5 matrix
  - Monoalphabetic Cipher - Single-key substitution system

- **User-friendly Interface**:
  - Color-coded menus and options
  - Clear visual feedback with boxed results
  - Interactive command-line experience

- **Dual Functionality**: Both encryption and decryption operations supported

## ⚙️ Requirements

- Windows operating system
- Microsoft Visual Studio with MASM support
- [Irvine32 Library](http://asmirvine.com/) for assembly routines

## 🛠️ Installation

1. **Clone the repository**:
   ```
   git clone https://github.com/yourusername/tactical-encryption-unit.git
   cd tactical-encryption-unit
   ```

2. **Set up Irvine32 Library**:
   - Download the Irvine library from [http://asmirvine.com/](http://asmirvine.com/)
   - Install it to `C:\Irvine\` (default path used in the project)
   - Alternative: Update the include path in `main.asm` if using a different location

3. **Build the Project**:
   - Open `tactical-encryption-unit.sln` in Visual Studio
   - Build the solution (F7 or Build → Build Solution)
   - The executable will be created in the Debug folder

## 🚀 Usage

1. Run the executable (`tactical-encryption-unit.exe`)
2. Select an operation:
   - 1: Encrypt a message
   - 2: Decrypt a message
   - 3: Exit
3. Choose a cipher method (1-6)
4. Enter the text to process and any required parameters (keys, shift values, etc.)
5. View the result and continue with another operation or exit

### Example Operations

#### Caesar Cipher
```
Enter the text: HELLO
Enter the shift value (1-25): 3
Result: KHOOR
```

#### Vigenère Cipher
```
Enter the text: TACTICAL
Enter the Vigenère keyword: KEY
Result: DIMDGAGP
```

#### Playfair Cipher
```
Enter the text: ASSEMBLY
Enter the Playfair keyword: CIPHER
Result: CMCFQCNS
```

## 📝 Technical Details

The project is developed in MASM (Microsoft Macro Assembler) and utilizes the Irvine32 library for input/output operations. The code implements various encryption algorithms at the assembly level, providing efficient execution and a deeper understanding of how these cryptographic techniques work at the lowest level.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add some amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgements

- [Irvine32 Library](http://asmirvine.com/) for assembly programming support
- Assembly language community for documentation and resources

---

<p align="center">
  <i>Developed with ❤️ for secure communications</i>
</p>
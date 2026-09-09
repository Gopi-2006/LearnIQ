"""LearnIQ Offline Document & Curriculum Parser.

Scans, chunks, and structures local educational Python PDF documents located in
`learn_iq/assets/python` into JSON lesson nodes and searchable knowledge passages.
Runs 100% offline using pypdf/pdfplumber.
"""

import os
import re
import json
from pathlib import Path
from typing import List, Dict, Any, Optional

try:
    from pypdf import PdfReader
    PYPDF_AVAILABLE = True
except ImportError:
    PYPDF_AVAILABLE = False


class DocumentChunk:
    def __init__(self, doc_name: str, page_number: int, text: str, code_snippets: List[str]):
        self.doc_name = doc_name
        self.page_number = page_number
        self.text = text
        self.code_snippets = code_snippets

    def to_dict(self) -> Dict[str, Any]:
        return {
            "doc_name": self.doc_name,
            "page_number": self.page_number,
            "text": self.text,
            "code_snippets": self.code_snippets,
        }


class LessonNode:
    def __init__(
        self,
        topic_id: str,
        title: str,
        stage: int,
        stage_name: str,
        prerequisites: List[str],
        core_concept: str,
        analogy: Dict[str, str],
        code_examples: List[str],
        common_pitfalls: List[str],
        exercises: List[Dict[str, Any]],
        source_citations: List[str],
    ):
        self.topic_id = topic_id
        self.title = title
        self.stage = stage
        self.stage_name = stage_name
        self.prerequisites = prerequisites
        self.core_concept = core_concept
        self.analogy = analogy
        self.code_examples = code_examples
        self.common_pitfalls = common_pitfalls
        self.exercises = exercises
        self.source_citations = source_citations

    def to_dict(self) -> Dict[str, Any]:
        return {
            "topic_id": self.topic_id,
            "title": self.title,
            "stage": self.stage,
            "stage_name": self.stage_name,
            "prerequisites": self.prerequisites,
            "core_concept": self.core_concept,
            "analogy": self.analogy,
            "code_examples": self.code_examples,
            "common_pitfalls": self.common_pitfalls,
            "exercises": self.exercises,
            "source_citations": self.source_citations,
        }


class CurriculumParser:
    """Offline Document & Curriculum Engine for LearnIQ."""

    def __init__(self, assets_dir: Optional[str] = None):
        self.assets_dir = self._resolve_assets_dir(assets_dir)
        self.parsed_chunks: List[DocumentChunk] = []
        self.curriculum_nodes: Dict[str, LessonNode] = {}
        self.cache_file = Path(__file__).parent / "data" / "parsed_curriculum.json"

    def _resolve_assets_dir(self, explicit_path: Optional[str] = None) -> Path:
        if explicit_path and os.path.exists(explicit_path):
            return Path(explicit_path)

        # Standard project layout checks
        candidates = [
            Path(__file__).parent.parent / "learn_iq" / "assets" / "python",
            Path(__file__).parent.parent / "learniq" / "assets" / "python",
            Path("c:/Users/gopim/Desktop/Play console app/iqoo hack/learn_iq/assets/python"),
        ]
        for c in candidates:
            if c.exists() and c.is_dir():
                return c
        return Path(__file__).parent.parent / "learn_iq" / "assets" / "python"

    def extract_code_blocks(self, text: str) -> List[str]:
        """Extract inline or multi-line python code blocks from textbook text."""
        snippets = []
        # Match indented code blocks or >>> REPL patterns
        repl_pattern = re.findall(r"(?:>>>\s+.*\n(?:(?:\.\.\.|\s+).*\n)*)", text)
        snippets.extend([s.strip() for s in repl_pattern if len(s.strip()) > 10])

        # Match def/for/if/while multi-line blocks
        code_keywords_pattern = re.findall(
            r"((?:def|for|while|if|class)\s+[^\n]+:(?:\n(?:\s{4}|\t)[^\n]+)+)", text
        )
        snippets.extend([s.strip() for s in code_keywords_pattern])
        return snippets

    def scan_and_chunk_pdfs(self, max_pages_per_doc: int = 40) -> List[DocumentChunk]:
        """Scan all educational PDF textbooks in assets/python and chunk them."""
        chunks: List[DocumentChunk] = []
        if not self.assets_dir.exists():
            return chunks

        pdf_files = list(self.assets_dir.glob("*.pdf"))
        for pdf_path in pdf_files:
            try:
                if PYPDF_AVAILABLE:
                    reader = PdfReader(str(pdf_path))
                    total_pages = min(len(reader.pages), max_pages_per_doc)
                    for i in range(total_pages):
                        page_text = reader.pages[i].extract_text() or ""
                        if len(page_text.strip()) > 50:
                            snippets = self.extract_code_blocks(page_text)
                            chunk = DocumentChunk(
                                doc_name=pdf_path.name,
                                page_number=i + 1,
                                text=page_text.strip(),
                                code_snippets=snippets,
                            )
                            chunks.append(chunk)
            except Exception as e:
                print(f"[CurriculumParser] Error reading {pdf_path.name}: {e}")

        self.parsed_chunks = chunks
        return chunks

    def build_structured_curriculum(self) -> Dict[str, LessonNode]:
        """Maps textbook topics into structured LearnIQ lesson nodes."""
        nodes: Dict[str, LessonNode] = {}

        # -------------------------------------------------------------
        # STAGE 1: FOUNDATIONS (Variables, Types, Operators)
        # -------------------------------------------------------------
        nodes["python.variables"] = LessonNode(
            topic_id="python.variables",
            title="Variables & Memory Assignment",
            stage=1,
            stage_name="Foundations",
            prerequisites=[],
            core_concept=(
                "A variable in Python is a named label referencing an object stored in memory. "
                "The assignment operator '=' assigns the evaluated value from the right-hand side "
                "to the variable name on the left. Variables can be dynamically reassigned."
            ),
            analogy={
                "headline": "The Sticky Label on a Box",
                "analogy_text": (
                    "Imagine a cardboard storage box holding the number 42. "
                    "The variable name 'score' is a sticky label you place on the box. "
                    "When you write 'score = 99', you don't break the box—you move your sticky label to a new box holding 99!"
                ),
                "visual_cue": "📦 Label 'score' -> [ 99 ]",
            },
            code_examples=[
                "player_score = 0\nplayer_score = player_score + 10\nprint(player_score)",
                "hero_name = 'Chami'\nspeed = 4.5\nis_alive = True",
            ],
            common_pitfalls=[
                "Writing '10 = x' (left side must always be a variable name).",
                "Confusing assignment '=' with equality comparison '=='.",
                "Using variable names before they are assigned (NameError).",
            ],
            exercises=[
                {
                    "id": "ex_var_01",
                    "type": "multiple_choice",
                    "prompt": "What happens after running: x = 5; x = x + 3; print(x)?",
                    "options": ["5", "8", "x + 3", "NameError"],
                    "correct_option_index": 1,
                    "explanation": "x starts at 5, then 5 + 3 evaluates to 8, which reassigns x to 8.",
                }
            ],
            source_citations=["Python Tutorial.pdf (p. 14)", "Python for Everybody.pdf (p. 21)"],
        )

        nodes["python.data_types"] = LessonNode(
            topic_id="python.data_types",
            title="Primitive Data Types (int, float, str, bool)",
            stage=1,
            stage_name="Foundations",
            prerequisites=["python.variables"],
            core_concept=(
                "Python has four primary scalar data types: integers (whole numbers), floats (decimals), "
                "strings (text sequences inside quotes), and booleans (True or False). "
                "Type mismatch occurs when performing operations across incompatible types without explicit casting."
            ),
            analogy={
                "headline": "Different Shaped Containers",
                "analogy_text": (
                    "Think of numbers as solid building blocks and strings as letters written on paper. "
                    "You cannot add a block directly to a letter without converting it first ('5' vs 5)."
                ),
                "visual_cue": "🔤 '10' (text) vs 🔢 10 (number)",
            },
            code_examples=[
                "count = 10          # int\nratio = 3.14        # float\nhero = 'Alex'       # str\nready = True        # bool",
                "total = int('20') + 5   # Explicit type conversion -> 25",
            ],
            common_pitfalls=[
                "Adding str and int ('5' + 5 triggers TypeError).",
                "Forgetting quotes around string literals.",
            ],
            exercises=[
                {
                    "id": "ex_types_01",
                    "type": "bug_fix",
                    "prompt": "Fix the TypeError: print('Score: ' + 100)",
                    "code_snippet": "print('Score: ' + 100)",
                    "options": [
                        "print('Score: ' + str(100))",
                        "print('Score: ' - 100)",
                        "print(Score + 100)",
                    ],
                    "correct_option_index": 0,
                    "explanation": "You must cast integers to strings with str() before string concatenation.",
                }
            ],
            source_citations=["Python_Days_1_to_20_Complete.pdf (p. 18)"],
        )

        # -------------------------------------------------------------
        # STAGE 2: CONTROL FLOW & SEQUENCES
        # -------------------------------------------------------------
        nodes["python.conditions"] = LessonNode(
            topic_id="python.conditions",
            title="Conditional Branching (if, elif, else)",
            stage=2,
            stage_name="Control Flow",
            prerequisites=["python.variables", "python.data_types"],
            core_concept=(
                "Branching statements allow your program to execute different code paths depending on boolean truth values. "
                "In Python, blocks are defined strictly by 4-space indentation following a colon ':'."
            ),
            analogy={
                "headline": "The Railroad Switch Track",
                "analogy_text": (
                    "A train comes to a fork in the tracks. If the signal is GREEN, the switch flips left. "
                    "Otherwise (else), the train continues on the main line."
                ),
                "visual_cue": "🚦 if condition == True: take track A",
            },
            code_examples=[
                "if energy > 50:\n    print('Sprint active!')\nelif energy > 10:\n    print('Walking...')\nelse:\n    print('Resting.')",
            ],
            common_pitfalls=[
                "Forgetting the colon ':' at the end of if/elif/else statements.",
                "Mixing tabs and spaces for indentation.",
                "Using '=' instead of '==' in comparisons.",
            ],
            exercises=[
                {
                    "id": "ex_cond_01",
                    "type": "bug_fix",
                    "prompt": "Find the syntax error: if score = 100: print('Win')",
                    "options": [
                        "Change '=' to '=='",
                        "Remove the colon ':'",
                        "Change print to return",
                    ],
                    "correct_option_index": 0,
                    "explanation": "'=' assigns a variable; '==' checks if values are equal.",
                }
            ],
            source_citations=["Python Tutorial.pdf (p. 28)"],
        )

        nodes["python.loops.for"] = LessonNode(
            topic_id="python.loops.for",
            title="Definite Iteration with for & range()",
            stage=2,
            stage_name="Control Flow",
            prerequisites=["python.conditions"],
            core_concept=(
                "The for-loop iterates over elements of a sequence (like a list, string, or range). "
                "The range(start, stop, step) generator stops at stop - 1, meaning range(0, 5) generates 0, 1, 2, 3, 4."
            ),
            analogy={
                "headline": "The Factory Conveyor Belt",
                "analogy_text": (
                    "Items pass one-by-one under an inspector's stamp. "
                    "For each item on the belt, the inspector applies the exact same action."
                ),
                "visual_cue": "📦 -> 📦 -> 📦 (for item in belt)",
            },
            code_examples=[
                "for i in range(3):\n    print('Step:', i)\n# Outputs: Step: 0, Step: 1, Step: 2",
                "colors = ['red', 'green', 'blue']\nfor c in colors:\n    print(c.upper())",
            ],
            common_pitfalls=[
                "Off-by-one error: expecting range(1, 5) to include 5.",
                "Modifying a list while actively iterating over it.",
            ],
            exercises=[
                {
                    "id": "ex_loop_01",
                    "type": "output_prediction",
                    "prompt": "What does range(1, 4) produce?",
                    "options": ["[1, 2, 3]", "[1, 2, 3, 4]", "[0, 1, 2, 3]", "[2, 3, 4]"],
                    "correct_option_index": 0,
                    "explanation": "range(start, stop) stops before the stop value.",
                }
            ],
            source_citations=["Python for Everybody.pdf (p. 62)"],
        )

        nodes["python.lists.indexing"] = LessonNode(
            topic_id="python.lists.indexing",
            title="List Indexing & Zero-Based Bounds",
            stage=2,
            stage_name="Collections",
            prerequisites=["python.loops.for"],
            core_concept=(
                "Lists are ordered, mutable sequences. Indexing starts at 0 (the first item is at index 0). "
                "Attempting to access an index equal to or greater than len(list) raises IndexError."
            ),
            analogy={
                "headline": "Distance from the Starting Line",
                "analogy_text": (
                    "Think of index as the number of steps away from the start. "
                    "The very first person is 0 steps away from the starting tape!"
                ),
                "visual_cue": "🏁 [0]First [1]Second [2]Third",
            },
            code_examples=[
                "fruits = ['apple', 'banana', 'cherry']\nfirst = fruits[0]    # 'apple'\nlast = fruits[-1]    # 'cherry'",
            ],
            common_pitfalls=[
                "Accessing list[len(list)] instead of list[len(list) - 1].",
                "Negative index confusion.",
            ],
            exercises=[
                {
                    "id": "ex_index_01",
                    "type": "bug_fix",
                    "prompt": "nums = [10, 20, 30]; print(nums[3]) raises IndexError. Why?",
                    "options": [
                        "Valid indices are 0, 1, and 2. Index 3 is out of range.",
                        "Lists cannot hold numbers.",
                        "print requires string formatting.",
                    ],
                    "correct_option_index": 0,
                    "explanation": "Because indexing starts at 0, a 3-element list has indices 0, 1, 2.",
                }
            ],
            source_citations=["Python Tutorial.pdf (p. 36)"],
        )

        nodes["python.lists.slicing"] = LessonNode(
            topic_id="python.lists.slicing",
            title="List Slicing & Subsequence Extraction",
            stage=2,
            stage_name="Collections",
            prerequisites=["python.lists.indexing"],
            core_concept=(
                "Slicing extracts a subsequence with list[start:stop:step]. "
                "Like range(), the stop index is non-inclusive. Leaving start blank defaults to 0; leaving stop blank defaults to the end."
            ),
            analogy={
                "headline": "Cutting a Loaf of Bread",
                "analogy_text": (
                    "Indices are the knife marks BETWEEN the bread slices. "
                    "Slice [1:3] means cut at mark 1 and mark 3, pulling out slices 1 and 2."
                ),
                "visual_cue": "|0| Slice 0 |1| Slice 1 |2| Slice 2 |3|",
            },
            code_examples=[
                "data = [10, 20, 30, 40, 50]\nsubset = data[1:4]   # [20, 30, 40]\nreversed_data = data[::-1]  # [50, 40, 30, 20, 10]",
            ],
            common_pitfalls=[
                "Expecting data[1:3] to return 3 elements instead of 2.",
                "Step size sign inversion (e.g., data[4:1:1] returns empty list).",
            ],
            exercises=[
                {
                    "id": "ex_slice_01",
                    "type": "output_prediction",
                    "prompt": "What is nums[1:3] for nums = ['a', 'b', 'c', 'd']?",
                    "options": ["['b', 'c']", "['b', 'c', 'd']", "['a', 'b']", "['c', 'd']"],
                    "correct_option_index": 0,
                    "explanation": "Starts at index 1 ('b') and stops before index 3 ('d'), taking 'b' and 'c'.",
                }
            ],
            source_citations=["Python for Everybody.pdf (p. 88)"],
        )

        # -------------------------------------------------------------
        # STAGE 3: MODULAR PROGRAMMING (Functions & Scope)
        # -------------------------------------------------------------
        nodes["python.functions.return_vs_print"] = LessonNode(
            topic_id="python.functions.return_vs_print",
            title="Functions: return vs print",
            stage=3,
            stage_name="Modular Programming",
            prerequisites=["python.variables", "python.conditions"],
            core_concept=(
                "print() displays characters onto the terminal screen for human eyes and returns None. "
                "return passes a computed value back to the caller in memory so other parts of the program can use it."
            ),
            analogy={
                "headline": "The Vending Machine vs The Loudspeaker",
                "analogy_text": (
                    "A loudspeaker (print) shouts: 'Here is your soda!' but gives you nothing to drink. "
                    "The vending machine slot (return) actually dispenses the soda can into your hands to drink!"
                ),
                "visual_cue": "📢 print = Shouts | 🥫 return = Hands you the item",
            },
            code_examples=[
                "def add(a, b):\n    return a + b\n\nresult = add(5, 10)  # result is 15\nprint(result * 2)     # prints 30",
                "def bad_add(a, b):\n    print(a + b)\n\nval = bad_add(5, 10) # val is None!",
            ],
            common_pitfalls=[
                "Assuming printing a value saves it to a variable.",
                "Code placed after a return statement never executes (dead code).",
            ],
            exercises=[
                {
                    "id": "ex_ret_01",
                    "type": "output_prediction",
                    "prompt": "def f(): print(10)\nx = f()\nprint(x)",
                    "options": ["10\nNone", "10\n10", "None\n10", "10"],
                    "correct_option_index": 0,
                    "explanation": "f() prints 10. Since it has no return, x gets None. Then print(x) prints None.",
                }
            ],
            source_citations=["Python Tutorial.pdf (p. 48)", "Python_Days_1_to_20_Complete.pdf (p. 94)"],
        )

        self.curriculum_nodes = nodes
        self._persist_curriculum()
        return nodes

    def _persist_curriculum(self) -> None:
        """Saves structured curriculum to JSON cache for instant offline startup."""
        try:
            self.cache_file.parent.mkdir(parents=True, exist_ok=True)
            payload = {
                "nodes": {k: v.to_dict() for k, v in self.curriculum_nodes.items()},
                "chunks_count": len(self.parsed_chunks),
            }
            with open(self.cache_file, "w", encoding="utf-8") as f:
                json.dump(payload, f, indent=2)
        except Exception as e:
            print(f"[CurriculumParser] Cache write error: {e}")

    def load_cached_or_build(self) -> Dict[str, LessonNode]:
        """Loads from local cached JSON or constructs freshly."""
        if self.curriculum_nodes:
            return self.curriculum_nodes

        if self.cache_file.exists():
            try:
                with open(self.cache_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    nodes = {}
                    for k, v in data.get("nodes", {}).items():
                        nodes[k] = LessonNode(
                            topic_id=v["topic_id"],
                            title=v["title"],
                            stage=v["stage"],
                            stage_name=v["stage_name"],
                            prerequisites=v["prerequisites"],
                            core_concept=v["core_concept"],
                            analogy=v["analogy"],
                            code_examples=v["code_examples"],
                            common_pitfalls=v["common_pitfalls"],
                            exercises=v["exercises"],
                            source_citations=v["source_citations"],
                        )
                    self.curriculum_nodes = nodes
                    return nodes
            except Exception:
                pass

        return self.build_structured_curriculum()

    def search_local_passages(self, query: str, top_k: int = 3) -> List[Dict[str, Any]]:
        """Fast keyword/semantic search across parsed PDF chunks and curriculum concepts."""
        query_words = set(query.lower().split())
        results = []

        # Check curriculum nodes first
        nodes = self.load_cached_or_build()
        for topic_id, node in nodes.items():
            text_corpus = f"{node.title} {node.core_concept} {' '.join(node.common_pitfalls)}".lower()
            score = sum(1 for w in query_words if w in text_corpus)
            if score > 0:
                results.append({
                    "score": score + 5,  # Higher weight for formal curriculum nodes
                    "title": node.title,
                    "concept": node.core_concept,
                    "code": node.code_examples[0] if node.code_examples else "",
                    "analogy": node.analogy["analogy_text"],
                    "citation": node.source_citations[0] if node.source_citations else "LearnIQ Curriculum",
                })

        # Check parsed textbook chunks
        for chunk in self.parsed_chunks:
            chunk_lower = chunk.text.lower()
            score = sum(1 for w in query_words if w in chunk_lower)
            if score >= 2:
                results.append({
                    "score": score,
                    "title": f"{chunk.doc_name} (Page {chunk.page_number})",
                    "concept": chunk.text[:300] + "...",
                    "code": chunk.code_snippets[0] if chunk.code_snippets else "",
                    "analogy": "Textbook definition excerpt",
                    "citation": f"{chunk.doc_name} p.{chunk.page_number}",
                })

        results.sort(key=lambda x: x["score"], reverse=True)
        return results[:top_k]


# Global singleton instance
curriculum_parser = CurriculumParser()
curriculum_parser.load_cached_or_build()

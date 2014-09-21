(* Capstone Disassembler Engine
* By Guillaume Jeanne <guillaume.jeanne@ensimag.fr>, 2014> *)

open Printf
open Capstone
open Xcore


let print_string_hex comment str =
	printf "%s" comment;
	for i = 0 to (Array.length str - 1) do
		printf "0x%02x " str.(i)
	done;
	printf "\n"


let _XCORE_CODE = "\xfe\x0f\xfe\x17\x13\x17\xc6\xfe\xec\x17\x97\xf8\xec\x4f\x1f\xfd\xec\x37\x07\xf2\x45\x5b\xf9\xfa\x02\x06\x1b\x10";;

let all_tests = [
        (CS_ARCH_XCORE, [CS_MODE_LITTLE_ENDIAN], _XCORE_CODE, "XCore");
];;

let print_op csh i op =
	( match op with
	| XCORE_OP_INVALID _ -> ();	(* this would never happens *)
	| XCORE_OP_REG reg -> printf "\t\top[%d]: REG = %s\n" i (cs_reg_name csh reg);
	| XCORE_OP_IMM imm -> printf "\t\top[%d]: IMM = 0x%x\n" i imm;
	| XCORE_OP_MEM mem -> ( printf "\t\top[%d]: MEM\n" i;
		if mem.base != 0 then
			printf "\t\t\toperands[%u].mem.base: REG = %s\n" i (cs_reg_name csh mem.base);
		if mem.index != 0 then
			printf "\t\t\toperands[%u].mem.index: 0x%x\n" i mem.index;
		if mem.displ != 0 then
			printf "\t\t\toperands[%u].mem.disp: 0x%x\n" i mem.displ;
		if mem.direct != 0 then
			printf "\t\t\toperands[%u].mem.direct: 0x%x\n" i mem.direct;
		);
	);

	();;


let print_detail csh arch =
	match arch with
	| CS_INFO_ARM _ -> ();
	| CS_INFO_ARM64 _ -> ();
	| CS_INFO_MIPS _ -> ();
	| CS_INFO_X86 _ -> ();
	| CS_INFO_PPC _ -> ();
	| CS_INFO_SPARC _ -> ();
	| CS_INFO_SYSZ _ -> ();
	| CS_INFO_XCORE xcore ->

	(* print all operands info (type & value) *)
	if (Array.length xcore.operands) > 0 then (
		printf "\top_count: %d\n" (Array.length xcore.operands);
		Array.iteri (print_op csh) xcore.operands;
	);
	printf "\n";;


let print_insn mode insn =
	printf "0x%x\t%s\t%s\n" insn.address insn.mnemonic insn.op_str;
	let csh = cs_open CS_ARCH_XCORE mode in
	match csh with
	| None -> ()
	| Some v -> print_detail v insn.arch


let print_arch x =
	let (arch, mode, code, comment) = x in
		let insns = cs_disasm_quick arch mode code 0x1000L 0L in
			printf "*************\n";
			printf "Platform: %s\n" comment;
			List.iter (print_insn mode) insns;;



List.iter print_arch all_tests;;



(* all below code use OO class of Capstone *)
let print_insn_cls csh insn =
	printf "0x%x\t%s\t%s\n" insn#address insn#mnemonic insn#op_str;
	print_detail csh insn#arch;;


let print_arch_cls x =
	let (arch, mode, code, comment) = x in (
		let d = new cs arch mode in
			let insns = d#disasm code 0x1000L 0L in
				printf "*************\n";
				printf "Platform: %s\n" comment;
				List.iter (print_insn_cls d#get_csh) insns;
	);;

List.iter print_arch_cls all_tests;;